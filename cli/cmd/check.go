package cmd

import (
	"fmt"
	"strings"

	"github.com/nexus-shell/nexus/cli/internal/runner"
	"github.com/nexus-shell/nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var checkCmd = &cobra.Command{
	Use:   "check",
	Short: "Check all build dependencies",
	Long:  "Verify that all tools required to build and run Nexus are installed.",
	RunE:  runCheck,
}

func init() {
	rootCmd.AddCommand(checkCmd)
}

// dep represents a single dependency check.
type dep struct {
	name     string
	binary   string
	versionF func() string // returns version string or ""
	required bool
}

func runCheck(_ *cobra.Command, _ []string) error {
	ui.Header("Nexus Dependency Check")

	deps := []dep{
		{
			name:   "CMake",
			binary: "cmake",
			versionF: func() string {
				out, err := runner.Output("cmake", "--version")
				if err != nil {
					return ""
				}
				// "cmake version 3.28.1" → "3.28.1"
				parts := strings.Fields(out)
				if len(parts) >= 3 {
					return parts[2]
				}
				return out
			},
			required: true,
		},
		{
			name:   "GCC",
			binary: "gcc",
			versionF: func() string {
				out, err := runner.Output("gcc", "--version")
				if err != nil {
					return ""
				}
				lines := strings.Split(out, "\n")
				if len(lines) > 0 {
					parts := strings.Fields(lines[0])
					return parts[len(parts)-1]
				}
				return ""
			},
			required: false, // clang is an alternative
		},
		{
			name:   "Clang",
			binary: "clang",
			versionF: func() string {
				out, err := runner.Output("clang", "--version")
				if err != nil {
					return ""
				}
				// "clang version 17.0.6" → "17.0.6"
				for _, word := range strings.Fields(out) {
					if len(word) > 0 && word[0] >= '0' && word[0] <= '9' {
						return word
					}
				}
				return out
			},
			required: false,
		},
		{
			name:   "Qt6 (qmake)",
			binary: "qmake6",
			versionF: func() string {
				// try qmake6 first, then qmake
				for _, bin := range []string{"qmake6", "qmake"} {
					out, err := runner.Output(bin, "--version")
					if err != nil {
						continue
					}
					// "QMake version 3.1\nUsing Qt version 6.6.1"
					for _, line := range strings.Split(out, "\n") {
						if strings.Contains(line, "Qt version") {
							parts := strings.Fields(line)
							return parts[len(parts)-1]
						}
					}
				}
				return ""
			},
			required: true,
		},
		{
			name:   "Qt6 (qmlscene)",
			binary: "qmlscene",
			versionF: func() string {
				// qmlscene is in qt6-tools on most distros
				if runner.Which("qmlscene") {
					return "found"
				}
				return ""
			},
			required: false,
		},
		{
			name:   "Ninja",
			binary: "ninja",
			versionF: func() string {
				out, err := runner.Output("ninja", "--version")
				if err != nil {
					return ""
				}
				return strings.TrimSpace(out)
			},
			required: false,
		},
		{
			name:   "pkg-config",
			binary: "pkg-config",
			versionF: func() string {
				out, err := runner.Output("pkg-config", "--version")
				if err != nil {
					return ""
				}
				return strings.TrimSpace(out)
			},
			required: true,
		},
		{
			name:   "awww",
			binary: "awww",
			versionF: func() string {
				out, err := runner.Output("awww", "--version")
				if err != nil {
					return ""
				}
				return strings.TrimSpace(out)
			},
			required: false,
		},
		{
			name:   "grim",
			binary: "grim",
			versionF: func() string {
				if runner.Which("grim") {
					return "found"
				}
				return ""
			},
			required: false,
		},
		{
			name:   "slurp",
			binary: "slurp",
			versionF: func() string {
				if runner.Which("slurp") {
					return "found"
				}
				return ""
			},
			required: false,
		},
	}

	fmt.Println()
	fmt.Printf("  %-20s %-10s %s\n", "Dependency", "Status", "Version")
	fmt.Printf("  %-20s %-10s %s\n",
		strings.Repeat("─", 18),
		strings.Repeat("─", 8),
		strings.Repeat("─", 12),
	)

	allRequired := true
	hasCompiler := false

	for _, d := range deps {
		found := runner.Which(d.binary)
		version := ""
		if found {
			version = d.versionF()
			if version == "" {
				version = "found"
			}
			if d.binary == "gcc" || d.binary == "clang" {
				hasCompiler = true
			}
		}
		if d.required && !found {
			allRequired = false
		}
		ui.CheckRow(d.name, version, found)
	}

	fmt.Println()

	// Compiler check (need at least one of gcc/clang)
	if hasCompiler {
		ui.Success("C++ compiler found")
	} else {
		ui.Error("No C++ compiler found — install gcc or clang")
		allRequired = false
	}

	// Qt6 DBus check via pkg-config
	if out, err := runner.Output("pkg-config", "--modversion", "Qt6DBus"); err == nil {
		ui.Success("Qt6DBus found (%s)", strings.TrimSpace(out))
	} else {
		ui.Warn("Qt6DBus not found via pkg-config (may still work if Qt6 is installed)")
	}

	fmt.Println()
	if allRequired {
		ui.Success("All required dependencies satisfied — ready to build")
		return nil
	}

	ui.Error("Some required dependencies are missing")
	return fmt.Errorf("dependency check failed")
}
