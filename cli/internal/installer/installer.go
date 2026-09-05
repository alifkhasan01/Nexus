// Package installer handles cloning the Nexus repo and copying runtime assets.
package installer

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/alifkhasan01/nexus/cli/internal/ui"
)

const (
	// DefaultRepo is the canonical upstream repository URL.
	DefaultRepo = "https://github.com/alifkhasan01/nexus.git"

	// DefaultBranch is the branch pulled when no --branch is specified.
	DefaultBranch = "main"

	// DefaultCloneDir is where the repo is placed inside XDG_DATA_HOME.
	DefaultCloneDir = "nexus/source"

	// QmlDestDir is where QML files are copied relative to XDG_DATA_HOME.
	QmlDestDir = "nexus/qml"
)

// Options controls the setup behaviour.
type Options struct {
	Repo      string // git remote URL
	Branch    string // git branch / tag
	CloneDir  string // absolute path to clone into (resolved by caller)
	QmlDir    string // absolute path to install QML assets into
	BinDir    string // absolute path for the final binary (e.g. ~/.local/bin)
	Reinstall bool   // wipe existing clone dir before cloning
}

// Clone clones (or updates) the repository.
// If the target directory already exists and Reinstall is false, it runs
// `git pull` instead to update in place.
func Clone(opts Options) error {
	if opts.Reinstall {
		if err := os.RemoveAll(opts.CloneDir); err != nil {
			return fmt.Errorf("could not remove existing directory: %w", err)
		}
	}

	if dirExists(opts.CloneDir + "/.git") {
		ui.Info("Repository already exists — pulling latest changes…")
		cmd := exec.Command("git", "-C", opts.CloneDir, "pull", "--ff-only")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("git pull failed: %w", err)
		}
		ui.Success("Repository updated")
		return nil
	}

	ui.Info("Cloning %s (branch: %s)…", opts.Repo, opts.Branch)
	if err := os.MkdirAll(filepath.Dir(opts.CloneDir), 0o755); err != nil {
		return fmt.Errorf("could not create parent directory: %w", err)
	}

	cmd := exec.Command("git", "clone",
		"--depth=1",
		"--branch", opts.Branch,
		opts.Repo,
		opts.CloneDir,
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("git clone failed: %w", err)
	}
	ui.Success("Clone complete → %s", opts.CloneDir)
	return nil
}

// CopyQML copies the qml/ directory from the cloned source into the runtime
// data directory so the nexus binary can find it after installation.
func CopyQML(srcRoot, destDir string) error {
	srcQML := filepath.Join(srcRoot, "qml")
	if !dirExists(srcQML) {
		return fmt.Errorf("qml/ not found inside cloned repo at %s", srcQML)
	}

	ui.Info("Installing QML assets → %s", destDir)
	if err := os.RemoveAll(destDir); err != nil {
		return fmt.Errorf("could not clear existing QML destination: %w", err)
	}

	if err := copyDir(srcQML, destDir); err != nil {
		return fmt.Errorf("QML copy failed: %w", err)
	}
	ui.Success("QML assets installed")
	return nil
}

// CopyBinary copies the compiled binary from srcBin to destDir/nexus atomically.
func CopyBinary(srcBin, destDir string) error {
	if err := os.MkdirAll(destDir, 0o755); err != nil {
		return fmt.Errorf("could not create %s: %w", destDir, err)
	}

	dest := filepath.Join(destDir, "nexus")
	tmp := dest + ".tmp"

	in, err := os.Open(srcBin)
	if err != nil {
		return err
	}
	defer in.Close()

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

	if err := os.Chmod(tmp, 0o755); err != nil {
		os.Remove(tmp)
		return err
	}
	return os.Rename(tmp, dest)
}

// DataHome returns the XDG_DATA_HOME directory (defaults to ~/.local/share).
func DataHome() string {
	if d := os.Getenv("XDG_DATA_HOME"); d != "" {
		return d
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".local", "share")
}

// ─── helpers ─────────────────────────────────────────────────────────────────

func dirExists(path string) bool {
	fi, err := os.Stat(path)
	return err == nil && fi.IsDir()
}

// copyDir recursively copies src directory to dst, preserving file modes.
func copyDir(src, dst string) error {
	return filepath.WalkDir(src, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}
		target := filepath.Join(dst, rel)

		if d.IsDir() {
			return os.MkdirAll(target, 0o755)
		}

		return copyFile(path, target)
	})
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return err
	}

	out, err := os.Create(dst)
	if err != nil {
		return err
	}

	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}
