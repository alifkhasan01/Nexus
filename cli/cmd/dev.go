package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"syscall"
	"time"

	"github.com/fsnotify/fsnotify"
	internalbuild "github.com/nexus-shell/nexus/cli/internal/build"
	"github.com/nexus-shell/nexus/cli/internal/project"
	"github.com/nexus-shell/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var (
	devSkipBuild  bool
	devNoWatch    bool
	devDebounceMs int
	devRelease    bool
	devJobs       int
	devVerbose    bool
)

var devCmd = &cobra.Command{
	Use:   "dev",
	Short: "Build and run Nexus with QML hot-reload",
	Long: `Build Nexus then launch it with a QML file watcher.

When a .qml file changes, the running process receives SIGUSR1 which
triggers QuickShell's built-in QML reload — no full restart needed.
C++ source changes trigger a rebuild and full restart automatically.`,
	RunE: runDev,
}

func init() {
	devCmd.Flags().BoolVar(&devSkipBuild, "skip-build", false, "Skip initial build step")
	devCmd.Flags().BoolVar(&devNoWatch, "no-watch", false, "Run without file watcher")
	devCmd.Flags().IntVar(&devDebounceMs, "debounce", 300, "Debounce delay in ms before reacting to file changes")
	devCmd.Flags().BoolVar(&devRelease, "release", false, "Build with CMAKE_BUILD_TYPE=Release")
	devCmd.Flags().IntVarP(&devJobs, "jobs", "j", runtime.NumCPU(), "Parallel compile jobs")
	devCmd.Flags().BoolVarP(&devVerbose, "verbose", "v", false, "Verbose build output")
	rootCmd.AddCommand(devCmd)
}

func runDev(_ *cobra.Command, _ []string) error {
	root, err := project.Root()
	if err != nil {
		return err
	}

	buildType := "Debug"
	if devRelease {
		buildType = "Release"
	}

	ui.Header("Nexus Dev Mode")
	ui.Label("Project root", root)
	ui.Label("Build type", buildType)
	ui.Label("Jobs", fmt.Sprintf("%d", devJobs))
	ui.Label("Watch", fmt.Sprintf("%v", !devNoWatch))
	fmt.Println()

	// ── Initial build ─────────────────────────────────────────────────────────
	if !devSkipBuild {
		ui.Step("Building (%s)…", buildType)
		if err := devBuild(root); err != nil {
			return fmt.Errorf("initial build failed: %w", err)
		}
		ui.Success("Build complete")
		fmt.Println()
	}

	binary := project.BinaryPath(root)
	if !project.Exists(binary) {
		return fmt.Errorf("binary not found at %s", binary)
	}

	// ── Launch process ────────────────────────────────────────────────────────
	proc, err := startNexus(root, binary)
	if err != nil {
		return err
	}

	ui.Success("nexus running (pid %d)", proc.Process.Pid)
	fmt.Println()

	if devNoWatch {
		return waitProc(proc)
	}

	// ── File watcher ──────────────────────────────────────────────────────────
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("failed to create watcher: %w", err)
	}
	defer watcher.Close()

	// Watch qml/ tree
	qmlDir := project.QmlDir(root)
	if err := watchTree(watcher, qmlDir); err != nil {
		ui.Warn("Could not watch QML dir: %v", err)
	} else {
		ui.Info("Watching %s for QML changes…", qmlDir)
	}

	// Watch src/ tree for C++ changes
	srcDir := filepath.Join(root, "src")
	if err := watchTree(watcher, srcDir); err != nil {
		ui.Warn("Could not watch src dir: %v", err)
	} else {
		ui.Info("Watching %s for C++ changes…", srcDir)
	}
	fmt.Println()

	// ── Event loop ────────────────────────────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	procDone := make(chan error, 1)
	go func() { procDone <- proc.Wait() }()

	debounce := time.NewTimer(0)
	<-debounce.C // drain initial fire

	var pendingCpp bool

	for {
		select {
		case sig := <-quit:
			ui.Info("Received %v — shutting down", sig)
			if proc.Process != nil {
				_ = proc.Process.Signal(syscall.SIGTERM)
			}
			<-procDone
			return nil

		case err := <-procDone:
			if err != nil {
				ui.Error("nexus exited: %v", err)
			} else {
				ui.Info("nexus exited cleanly")
			}
			return nil

		case event, ok := <-watcher.Events:
			if !ok {
				return nil
			}
			if event.Op&(fsnotify.Write|fsnotify.Create|fsnotify.Remove) == 0 {
				continue
			}

			// Re-watch newly created directories so nested additions are tracked.
			if event.Op&fsnotify.Create != 0 {
				if info, err := os.Stat(event.Name); err == nil && info.IsDir() {
					if err := watchTree(watcher, event.Name); err == nil {
						ui.Info("Now watching new directory: %s", event.Name)
					}
					continue
				}
			}

			ext := filepath.Ext(event.Name)
			switch ext {
			case ".qml":
				ui.Info("QML changed: %s", filepath.Base(event.Name))
				debounce.Reset(time.Duration(devDebounceMs) * time.Millisecond)
				pendingCpp = false

			case ".cpp", ".h", ".hpp":
				ui.Info("C++ changed: %s — scheduling rebuild…", filepath.Base(event.Name))
				debounce.Reset(time.Duration(devDebounceMs) * time.Millisecond)
				pendingCpp = true
			}

		case <-debounce.C:
			if pendingCpp {
				// Full rebuild + restart
				ui.Step("C++ changed — rebuilding…")
				if proc.Process != nil {
					_ = proc.Process.Signal(syscall.SIGTERM)
					<-procDone
				}

				if err := devBuild(root); err != nil {
					ui.Error("Rebuild failed: %v — waiting for next change", err)
					// Relaunch even on failure to keep watcher alive
					proc, err = startNexus(root, binary)
					if err != nil {
						return err
					}
					procDone = make(chan error, 1)
					go func() { procDone <- proc.Wait() }()
					pendingCpp = false
					continue
				}

				ui.Success("Rebuild done — restarting nexus")
				proc, err = startNexus(root, binary)
				if err != nil {
					return err
				}
				procDone = make(chan error, 1)
				go func() { procDone <- proc.Wait() }()
				ui.Success("nexus restarted (pid %d)", proc.Process.Pid)

			} else {
				// QML-only change — send SIGUSR1 for hot-reload
				if proc.Process != nil {
					ui.Step("QML changed — sending hot-reload signal…")
					if err := proc.Process.Signal(syscall.SIGUSR1); err != nil {
						ui.Warn("Failed to send SIGUSR1: %v — restarting instead", err)
						_ = proc.Process.Signal(syscall.SIGTERM)
						<-procDone
						proc, err = startNexus(root, binary)
						if err != nil {
							return err
						}
						procDone = make(chan error, 1)
						go func() { procDone <- proc.Wait() }()
					} else {
						ui.Success("Hot-reload signal sent")
					}
				}
			}
			pendingCpp = false

		case watchErr, ok := <-watcher.Errors:
			if !ok {
				return nil
			}
			ui.Warn("Watcher error: %v", watchErr)
		}
	}
}

// devBuild runs a build using the flags set on the dev command.
func devBuild(root string) error {
	return internalbuild.Run(root, internalbuild.Options{
		Release: devRelease,
		Jobs:    devJobs,
		Verbose: devVerbose,
	})
}

// startNexus launches the nexus binary and returns the running *exec.Cmd.
func startNexus(root, binary string) (*exec.Cmd, error) {
	cmd := exec.Command(binary)
	cmd.Dir = root
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = nil

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("failed to start nexus: %w", err)
	}
	return cmd, nil
}

// waitProc waits for the process and handles signals gracefully.
func waitProc(cmd *exec.Cmd) error {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	done := make(chan error, 1)
	go func() { done <- cmd.Wait() }()

	select {
	case sig := <-quit:
		if cmd.Process != nil {
			_ = cmd.Process.Signal(sig)
		}
		return <-done
	case err := <-done:
		return err
	}
}

// watchTree recursively adds all subdirectories under root to the watcher.
func watchTree(w *fsnotify.Watcher, root string) error {
	return filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return nil // skip unreadable entries
		}
		if d.IsDir() {
			return w.Add(path)
		}
		return nil
	})
}
