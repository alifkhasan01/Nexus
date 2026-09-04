package cmd

import (
	"fmt"
	"os"
	"runtime"
	"strconv"

	internalbuild "github.com/alifkhasan01/Nexus/cli/internal/build"
	"github.com/alifkhasan01/Nexus/cli/internal/project"
	"github.com/alifkhasan01/Nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var (
	buildRelease     bool
	buildJobs        int
	buildVerbose     bool
	buildNoConfigure bool
)

var buildCmd = &cobra.Command{
	Use:   "build",
	Short: "Configure and compile Nexus",
	Long: `Run cmake configure (if needed) then compile the Nexus binary.

By default builds a Debug build. Use --release for an optimised build.`,
	RunE: runBuild,
}

func init() {
	buildCmd.Flags().BoolVar(&buildRelease, "release", false, "Build with CMAKE_BUILD_TYPE=Release")
	buildCmd.Flags().IntVarP(&buildJobs, "jobs", "j", runtime.NumCPU(), "Parallel compile jobs")
	buildCmd.Flags().BoolVarP(&buildVerbose, "verbose", "v", false, "Verbose build output")
	buildCmd.Flags().BoolVar(&buildNoConfigure, "no-configure", false, "Skip cmake configure step")
	rootCmd.AddCommand(buildCmd)
}

func runBuild(_ *cobra.Command, _ []string) error {
	root, err := project.Root()
	if err != nil {
		return err
	}

	buildType := "Debug"
	if buildRelease {
		buildType = "Release"
	}

	ui.Header(fmt.Sprintf("Building Nexus (%s)", buildType))
	ui.Label("Project root", root)
	ui.Label("Build dir", project.BuildDir(root))
	ui.Label("Build type", buildType)
	ui.Label("Jobs", strconv.Itoa(buildJobs))
	fmt.Println()

	opts := internalbuild.Options{
		Release:     buildRelease,
		Jobs:        buildJobs,
		Verbose:     buildVerbose,
		NoConfigure: buildNoConfigure,
	}

	if err := internalbuild.Run(root, opts); err != nil {
		return err
	}

	fmt.Println()
	binaryPath := project.BinaryPath(root)
	if project.Exists(binaryPath) {
		if info, err := os.Stat(binaryPath); err == nil {
			sizeMB := float64(info.Size()) / 1024 / 1024
			ui.Success("Build complete — nexus (%.1f MB)", sizeMB)
		} else {
			ui.Success("Build complete")
		}
		ui.Label("Binary", binaryPath)
	} else {
		ui.Warn("Build finished but binary not found at expected path: %s", binaryPath)
	}

	return nil
}
