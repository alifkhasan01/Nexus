package cmd

import (
	"fmt"
	"os"

	"github.com/nexus-shell/nexus/cli/internal/project"
	"github.com/nexus-shell/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var cleanForce bool

var cleanCmd = &cobra.Command{
	Use:   "clean",
	Short: "Remove the build directory",
	Long:  "Delete the build/ directory, forcing a full reconfigure on the next build.",
	RunE:  runClean,
}

func init() {
	cleanCmd.Flags().BoolVarP(&cleanForce, "force", "f", false, "Skip confirmation prompt")
	rootCmd.AddCommand(cleanCmd)
}

func runClean(_ *cobra.Command, _ []string) error {
	root, err := project.Root()
	if err != nil {
		return err
	}

	buildDir := project.BuildDir(root)

	if !project.Exists(buildDir) {
		ui.Info("Build directory does not exist — nothing to clean")
		return nil
	}

	// Get size for reporting
	size, _ := dirSize(buildDir)
	sizeMB := float64(size) / 1024 / 1024

	ui.Header("Clean Build Directory")
	ui.Label("Directory", buildDir)
	ui.Label("Size", fmt.Sprintf("%.1f MB", sizeMB))
	fmt.Println()

	if !cleanForce {
		fmt.Printf("  Remove %s? [y/N] ", buildDir)
		var answer string
		fmt.Scanln(&answer)
		if answer != "y" && answer != "Y" {
			ui.Info("Aborted")
			return nil
		}
	}

	ui.Step("Removing %s…", buildDir)
	if err := os.RemoveAll(buildDir); err != nil {
		return fmt.Errorf("failed to remove build directory: %w", err)
	}

	ui.Success("Build directory removed (%.1f MB freed)", sizeMB)
	return nil
}

// dirSize returns the total size in bytes of all files under path.
func dirSize(path string) (int64, error) {
	var total int64
	err := walkDir(path, func(info os.FileInfo) {
		if !info.IsDir() {
			total += info.Size()
		}
	})
	return total, err
}

func walkDir(path string, fn func(os.FileInfo)) error {
	entries, err := os.ReadDir(path)
	if err != nil {
		return err
	}
	for _, e := range entries {
		info, err := e.Info()
		if err != nil {
			continue
		}
		fn(info)
		if e.IsDir() {
			_ = walkDir(path+"/"+e.Name(), fn)
		}
	}
	return nil
}
