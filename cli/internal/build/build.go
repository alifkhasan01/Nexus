// Package build provides shared CMake configure+compile logic used by both
// the `build` and `dev` commands.
package build

import (
	"fmt"
	"runtime"

	"github.com/alifkhansen01/Nexus/cli/internal/project"
	"github.com/alifkhansen01/Nexus/cli/internal/runner"
	"github.com/alifkhansen01/Nexus/cli/internal/ui"
)

// Options controls how the project is compiled.
type Options struct {
	Release      bool   // true → CMAKE_BUILD_TYPE=Release
	Jobs         int    // parallel jobs; 0 = runtime.NumCPU()
	Verbose      bool   // pass --verbose to cmake --build
	NoConfigure  bool   // skip cmake configure when cache already exists
}

// DefaultOptions returns sensible defaults.
func DefaultOptions() Options {
	return Options{
		Jobs: runtime.NumCPU(),
	}
}

// Run configures (if needed) and compiles the project rooted at root.
// It prints progress via the ui package and streams build output to stdout/stderr.
func Run(root string, opts Options) error {
	buildDir := project.BuildDir(root)
	buildType := "Debug"
	if opts.Release {
		buildType = "Release"
	}
	jobs := opts.Jobs
	if jobs <= 0 {
		jobs = runtime.NumCPU()
	}

	// ── Configure ────────────────────────────────────────────────────────────
	needsConfigure := !opts.NoConfigure &&
		(!project.Exists(buildDir) || !project.Exists(buildDir+"/CMakeCache.txt"))

	// Guard: --no-configure requested but cache is missing — force configure.
	if opts.NoConfigure && !project.Exists(buildDir+"/CMakeCache.txt") {
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
	} else if !needsConfigure && !opts.NoConfigure {
		ui.Info("Build directory exists — skipping configure (use --no-configure=false to force)")
	}

	// ── Compile ──────────────────────────────────────────────────────────────
	ui.Step("Compiling…")

	compileArgs := []string{
		"--build", buildDir,
		"--parallel", fmt.Sprintf("%d", jobs),
	}
	if opts.Verbose {
		compileArgs = append(compileArgs, "--verbose")
	}

	if err := runner.Run(root, "cmake", compileArgs...); err != nil {
		return fmt.Errorf("build failed: %w", err)
	}

	return nil
}
