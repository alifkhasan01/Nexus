package cmd

import (
	"fmt"
	"os"
	"runtime"
	"strconv"

	"github.com/nexus-shell/nexus/cli/internal/project"
	"github.com/nexus-shell/nexus/cli/internal/runner"
	"github.com/nexus-shell/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var (
	buildRelease bool
	buildJobs    int
	buildVerbose bool
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

	buildDir := project.BuildDir(root)
	buildType := "Debug"
	if buildRelease {
		buildType = "Release"
	}

	ui.Header(fmt.Sprintf("Building Nexus (%s)", buildType))
	ui.Label("Project root", root)
	ui.Label("Build dir", buildDir)
	ui.Label("Build type", buildType)
	ui.Label("Jobs", strconv.Itoa(buildJobs))
	fmt.Println()

	// ── Configure ────────────────────────────────────────────
	needsConfigure := buildNoConfigure == false &&
		(!project.Exists(buildDir) || !project.Exists(buildDir+"/CMakeCache.txt"))

	if buildNoConfigure && !project.Exists(buildDir+"/CMakeCache.txt") {
		ui.Warn("--no-configure set but build dir has no CMakeCache.txt — forcing configure")
		needsConfigure = true
	}

	if needsConfigure {
		ui.Step("Configuring with CMake…")

		configArgs := []string{
			"-B", buildDir,
			"-S", root,
			"-DCMAKE_BUILD_TYPE=" + buildType,
			"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
		}

		// Prefer Ninja if available
		if runner.Which("ninja") {
			configArgs = append(configArgs, "-GNinja")
			ui.Info("Generator: Ninja")
		} else {
			ui.Info("Generator: Unix Makefiles")
		}

		if err := runner.Run(root, "cmake", configArgs...); err != nil {
			return fmt.Errorf("cmake configure failed: %w", err)
		}
		ui.Success("Configure done")
		fmt.Println()
	} else {
		ui.Info("Build directory exists — skipping configure (use --no-configure=false to force)")
	}

	// ── Compile ───────────────────────────────────────────────
	ui.Step("Compiling…")

	compileArgs := []string{
		"--build", buildDir,
		"--parallel", strconv.Itoa(buildJobs),
	}
	if buildVerbose {
		compileArgs = append(compileArgs, "--verbose")
	}

	if err := runner.Run(root, "cmake", compileArgs...); err != nil {
		return fmt.Errorf("build failed: %w", err)
	}

	fmt.Println()
	binaryPath := project.BinaryPath(root)
	if project.Exists(binaryPath) {
		// Get binary size
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
