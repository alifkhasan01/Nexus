package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/alifkhasan01/nexus/cli/internal/installer"
	"github.com/alifkhasan01/nexus/cli/internal/runner"
	"github.com/alifkhasan01/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

const cliModulePath = "github.com/alifkhasan01/nexus/cli/cmd/nexusctl"

var (
	upgradeShell  bool
	upgradePrefix string
	upgradeJobs   int
)

var upgradeCmd = &cobra.Command{
	Use:   "upgrade",
	Short: "Upgrade the nexus CLI (and optionally the shell)",
	Long: `Upgrade the nexus CLI binary to the latest version from the upstream
repository using 'go install', then optionally upgrade the Nexus shell as well.

Examples:

  # Upgrade CLI only
  nexus upgrade

  # Upgrade CLI + rebuild and reinstall the shell
  nexus upgrade --shell

  # Custom binary install prefix for the shell
  nexus upgrade --shell --prefix /usr/local`,
	RunE: runUpgrade,
}

func init() {
	home, _ := os.UserHomeDir()

	upgradeCmd.Flags().BoolVar(&upgradeShell, "shell", false, "Also upgrade (pull + rebuild + reinstall) the Nexus shell")
	upgradeCmd.Flags().StringVar(&upgradePrefix, "prefix", filepath.Join(home, ".local"), "Install prefix for the shell binary (used with --shell)")
	upgradeCmd.Flags().IntVarP(&upgradeJobs, "jobs", "j", runtime.NumCPU(), "Parallel compile jobs (used with --shell)")

	rootCmd.AddCommand(upgradeCmd)
}

func runUpgrade(_ *cobra.Command, _ []string) error {
	ui.Header("Nexus Upgrade")
	fmt.Println()

	// ── Step 1: Upgrade CLI via go install ───────────────────────────────────
	ui.Step("Upgrading CLI (%s@latest)…", cliModulePath)

	if !runner.Which("go") {
		return fmt.Errorf("'go' not found in PATH — cannot upgrade CLI\n" +
			"Install Go from https://go.dev/dl/ or via your package manager")
	}

	goInstallPkg := cliModulePath + "@latest"
	cmd := exec.Command("go", "install", goInstallPkg)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = os.Environ()
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("go install failed: %w", err)
	}

	newBin := resolveInstalledBin()
	ui.Success("CLI upgraded → %s", newBin)
	fmt.Println()

	// ── Step 2 (optional): Upgrade shell ─────────────────────────────────────
	if upgradeShell {
		ui.Step("Upgrading Nexus shell…")
		fmt.Println()

		dataHome := installer.DataHome()
		cloneDir := filepath.Join(dataHome, installer.DefaultCloneDir)
		qmlDest := filepath.Join(dataHome, installer.QmlDestDir)
		binDir := filepath.Join(upgradePrefix, "bin")

		// Pull latest source
		ui.Step("Pulling latest source…")
		if err := installer.Clone(installer.Options{
			Repo:     installer.DefaultRepo,
			Branch:   installer.DefaultBranch,
			CloneDir: cloneDir,
		}); err != nil {
			return fmt.Errorf("source update failed: %w", err)
		}
		fmt.Println()

		// Rebuild
		ui.Step("Rebuilding shell (%d jobs)…", upgradeJobs)

		// Use the runner directly so we can pass --no-configure=false to force
		// a fresh configure after a pull (CMakeLists.txt may have changed).
		buildDir := filepath.Join(cloneDir, "build")
		configArgs := []string{
			"-B", buildDir,
			"-S", cloneDir,
			"-DCMAKE_BUILD_TYPE=Debug",
			"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
		}
		if runner.Which("ninja") {
			configArgs = append(configArgs, "-GNinja")
		}
		if err := runner.Run(cloneDir, "cmake", configArgs...); err != nil {
			return fmt.Errorf("cmake configure failed: %w", err)
		}

		compileArgs := []string{
			"--build", buildDir,
			"--parallel", fmt.Sprintf("%d", upgradeJobs),
		}
		if err := runner.Run(cloneDir, "cmake", compileArgs...); err != nil {
			return fmt.Errorf("rebuild failed: %w", err)
		}
		ui.Success("Rebuild complete")
		fmt.Println()

		// Install binary
		binaryPath := filepath.Join(buildDir, "nexus")
		if _, err := os.Stat(binaryPath); err != nil {
			return fmt.Errorf("binary not found at %s after build", binaryPath)
		}
		ui.Step("Installing shell binary → %s…", filepath.Join(binDir, "nexus"))
		if err := installer.CopyBinary(binaryPath, binDir); err != nil {
			return fmt.Errorf("binary install failed: %w", err)
		}
		ui.Success("Shell binary installed")
		fmt.Println()

		// Install QML assets
		ui.Step("Installing QML assets…")
		if err := installer.CopyQML(cloneDir, qmlDest); err != nil {
			return fmt.Errorf("QML install failed: %w", err)
		}
		fmt.Println()

		// Install QML plugin
		pluginLibDir := filepath.Join(dataHome, "nexus", "qml-plugin")
		ui.Step("Installing QML plugin…")
		if err := installer.CopyQmlPlugin(buildDir, pluginLibDir); err != nil {
			return fmt.Errorf("QML plugin install failed: %w", err)
		}
		fmt.Println()

		ui.Success("Shell upgraded")
		ui.Label("Binary", filepath.Join(binDir, "nexus"))
		ui.Label("QML assets", qmlDest)
		ui.Label("QML plugin", pluginLibDir)
		fmt.Println()
	}

	// ── Done ─────────────────────────────────────────────────────────────────
	ui.Success("Upgrade complete!")
	if !upgradeShell {
		fmt.Println()
		ui.Info("To also upgrade the shell, run: nexus upgrade --shell")
	}
	return nil
}

// resolveInstalledBin returns the path where go install placed the binary.
// It checks GOBIN, then GOPATH/bin, then ~/go/bin.
func resolveInstalledBin() string {
	if gobin := os.Getenv("GOBIN"); gobin != "" {
		return filepath.Join(gobin, "nexusctl")
	}
	if out, err := exec.Command("go", "env", "GOPATH").Output(); err == nil {
		gopath := strings.TrimSpace(string(out))
		if gopath != "" {
			return filepath.Join(gopath, "bin", "nexusctl")
		}
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, "go", "bin", "nexusctl")
}
