package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"

	internalbuild "github.com/alifkhasan01/nexus/cli/internal/build"
	"github.com/alifkhasan01/nexus/cli/internal/installer"
	"github.com/alifkhasan01/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var (
	setupRepo      string
	setupBranch    string
	setupPrefix    string
	setupReinstall bool
	setupJobs      int
	setupRelease   bool
	setupSkipBuild bool
)

var setupCmd = &cobra.Command{
	Use:   "setup",
	Short: "Install Nexus from scratch (no manual clone needed)",
	Long: `Clone the Nexus repository, build it, and install the binary + QML
assets to your system — all in one command.

By default the source is cloned to $XDG_DATA_HOME/nexus/source and the
binary is installed to ~/.local/bin/nexus.

Examples:

  # Standard one-shot install
  nexus setup

  # Use a specific branch or fork
  nexus setup --branch dev
  nexus setup --repo https://github.com/yourfork/nexus.git

  # Reinstall cleanly (wipes existing clone)
  nexus setup --reinstall

  # Build a release binary
  nexus setup --release`,
	RunE: runSetup,
}

func init() {
	home, _ := os.UserHomeDir()

	setupCmd.Flags().StringVar(&setupRepo, "repo", installer.DefaultRepo, "Git repository URL to clone from")
	setupCmd.Flags().StringVar(&setupBranch, "branch", installer.DefaultBranch, "Branch or tag to clone")
	setupCmd.Flags().StringVar(&setupPrefix, "prefix", filepath.Join(home, ".local"), "Install prefix for the nexus binary")
	setupCmd.Flags().BoolVar(&setupReinstall, "reinstall", false, "Wipe existing clone and start fresh")
	setupCmd.Flags().IntVarP(&setupJobs, "jobs", "j", runtime.NumCPU(), "Parallel compile jobs")
	setupCmd.Flags().BoolVar(&setupRelease, "release", false, "Build with CMAKE_BUILD_TYPE=Release")
	setupCmd.Flags().BoolVar(&setupSkipBuild, "skip-build", false, "Skip build step (only clone + install assets)")

	rootCmd.AddCommand(setupCmd)
}

func runSetup(_ *cobra.Command, _ []string) error {
	dataHome := installer.DataHome()
	cloneDir := filepath.Join(dataHome, installer.DefaultCloneDir)
	qmlDest := filepath.Join(dataHome, installer.QmlDestDir)
	binDir := filepath.Join(setupPrefix, "bin")

	buildType := "Debug"
	if setupRelease {
		buildType = "Release"
	}

	ui.Header("Nexus Setup")
	ui.Label("Repository", setupRepo)
	ui.Label("Branch", setupBranch)
	ui.Label("Source dir", cloneDir)
	ui.Label("QML assets", qmlDest)
	ui.Label("Binary", filepath.Join(binDir, "nexus"))
	ui.Label("Build type", buildType)
	fmt.Println()

	// ── Step 1: Clone / update ────────────────────────────────────────────────
	ui.Step("Fetching source…")
	if err := installer.Clone(installer.Options{
		Repo:      setupRepo,
		Branch:    setupBranch,
		CloneDir:  cloneDir,
		Reinstall: setupReinstall,
	}); err != nil {
		return err
	}
	fmt.Println()

	// ── Step 2: Build ─────────────────────────────────────────────────────────
	if !setupSkipBuild {
		ui.Step("Building (%s, %d jobs)…", buildType, setupJobs)
		if err := internalbuild.Run(cloneDir, internalbuild.Options{
			Release: setupRelease,
			Jobs:    setupJobs,
		}); err != nil {
			return fmt.Errorf("build failed: %w", err)
		}
		ui.Success("Build complete")
		fmt.Println()
	}

	// ── Step 3: Install binary ────────────────────────────────────────────────
	binaryPath := filepath.Join(cloneDir, "build", "nexus")
	if !setupSkipBuild {
		if _, err := os.Stat(binaryPath); err != nil {
			return fmt.Errorf("binary not found at %s after build — something went wrong", binaryPath)
		}

		ui.Step("Installing binary → %s…", filepath.Join(binDir, "nexus"))
		if err := installer.CopyBinary(binaryPath, binDir); err != nil {
			return fmt.Errorf("binary install failed: %w", err)
		}
		ui.Success("Binary installed")
		fmt.Println()
	}

	// ── Step 4: Install QML assets ────────────────────────────────────────────
	ui.Step("Installing QML assets…")
	if err := installer.CopyQML(cloneDir, qmlDest); err != nil {
		return fmt.Errorf("QML install failed: %w", err)
	}
	fmt.Println()

	// ── Done ──────────────────────────────────────────────────────────────────
	ui.Success("Nexus setup complete!")
	fmt.Println()
	ui.Label("Binary", filepath.Join(binDir, "nexus"))
	ui.Label("QML assets", qmlDest)
	ui.Label("Source", cloneDir)
	fmt.Println()

	// PATH hint
	inPath := false
	for _, p := range filepath.SplitList(os.Getenv("PATH")) {
		if p == binDir {
			inPath = true
			break
		}
	}
	if !inPath {
		ui.Warn("%s is not in your $PATH", binDir)
		ui.Info("Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):")
		ui.Info(`  export PATH="%s:$PATH"`, binDir)
		fmt.Println()
	}

	ui.Info("Run 'nexus run' to launch the shell, or add it to your compositor autostart.")
	return nil
}
