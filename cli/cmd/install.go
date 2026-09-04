package cmd

import (
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/alifkhasan01/nexus/cli/internal/project"
	"github.com/alifkhasan01/nexus/cli/internal/runner"
	"github.com/alifkhasan01/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var (
	installPrefix   string
	installCopyOnly bool
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Install the Nexus binary to ~/.local/bin",
	Long: `Run cmake --install then copy the nexus binary to ~/.local/bin
so it is available on $PATH without further configuration.

Use --prefix to override the cmake install prefix (default: ~/.local).
Use --copy-only to skip cmake --install and copy the binary from build/ directly.`,
	RunE: runInstall,
}

func init() {
	home, _ := os.UserHomeDir()
	defaultPrefix := filepath.Join(home, ".local")

	installCmd.Flags().StringVar(&installPrefix, "prefix", defaultPrefix, "cmake install prefix")
	installCmd.Flags().BoolVar(&installCopyOnly, "copy-only", false, "Skip cmake --install, copy binary from build/ directly")
	rootCmd.AddCommand(installCmd)
}

func runInstall(_ *cobra.Command, _ []string) error {
	root, err := project.Root()
	if err != nil {
		return err
	}

	srcBinary := project.BinaryPath(root)
	if !project.Exists(srcBinary) {
		return fmt.Errorf("binary not found at %s — run 'nexus build' first", srcBinary)
	}

	binDir := filepath.Join(installPrefix, "bin")
	dest := filepath.Join(binDir, "nexus")

	ui.Header("Installing Nexus")
	ui.Label("Source binary", srcBinary)
	ui.Label("Install prefix", installPrefix)
	ui.Label("Destination", dest)
	fmt.Println()

	// ── cmake --install ───────────────────────────────────────────────────────
	if !installCopyOnly {
		ui.Step("Running cmake --install…")
		if err := runner.Run(root, "cmake",
			"--install", project.BuildDir(root),
			"--prefix", installPrefix,
		); err != nil {
			return fmt.Errorf("cmake --install failed: %w", err)
		}
		ui.Success("cmake --install complete")
		fmt.Println()
	}

	// ── Copy binary to <prefix>/bin ───────────────────────────────────────────
	if err := os.MkdirAll(binDir, 0o755); err != nil {
		return fmt.Errorf("could not create %s: %w", binDir, err)
	}

	ui.Step("Copying binary to %s…", dest)
	if err := copyBinary(srcBinary, dest); err != nil {
		return fmt.Errorf("copy failed: %w", err)
	}
	if err := os.Chmod(dest, 0o755); err != nil {
		return fmt.Errorf("chmod failed: %w", err)
	}

	ui.Success("Installed → %s", dest)

	// Hint if binDir is not in PATH.
	if !inPath(binDir) {
		fmt.Println()
		ui.Warn("%s is not in your $PATH", binDir)
		ui.Info("Add the following to your shell profile:")
		ui.Info(`  export PATH="%s:$PATH"`, binDir)
	}

	return nil
}

// copyBinary copies the file at src to dst, replacing dst if it already exists.
func copyBinary(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	// Write to a temp file in the same dir, then rename for atomicity.
	tmp := dst + ".tmp"
	out, err := os.Create(tmp)
	if err != nil {
		return err
	}

	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		os.Remove(tmp)
		return err
	}
	if err := out.Sync(); err != nil {
		out.Close()
		os.Remove(tmp)
		return err
	}
	out.Close()

	return os.Rename(tmp, dst)
}

// inPath reports whether dir appears in the colon-separated $PATH.
func inPath(dir string) bool {
	for _, p := range filepath.SplitList(os.Getenv("PATH")) {
		if p == dir {
			return true
		}
	}
	return false
}
