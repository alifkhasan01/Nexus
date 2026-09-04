package cmd

import (
	"github.com/spf13/cobra"
)

// SilentError wraps an error that has already been displayed to the user by a
// subcommand (e.g. via ui.Error). main.go checks for this type to avoid
// printing the same message a second time.
type SilentError struct{ Cause error }

func (s SilentError) Error() string { return s.Cause.Error() }
func (s SilentError) Unwrap() error { return s.Cause }

var rootCmd = &cobra.Command{
	Use:   "nexus",
	Short: "Nexus shell developer CLI",
	Long: `nexus — developer tooling for the Nexus Wayland desktop shell.

Commands:
  check    Verify all build dependencies are present
  build    Configure and compile the project
  clean    Remove the build directory
  run      Launch the compiled shell binary
  dev      Build, run, and watch for file changes (hot-reload)
  install  Install the binary to ~/.local/bin`,
	SilenceUsage:  true,
	SilenceErrors: true,
}

// Execute is the entry point called from main.go.
func Execute() error {
	return rootCmd.Execute()
}

func init() {
	// Suppress cobra's default "Error:" prefix — we print our own.
	rootCmd.SetErrPrefix("")

	// Custom usage template with colour hints.
	rootCmd.SetHelpTemplate(`{{.Long}}

Usage:
  {{.UseLine}}{{if .HasAvailableSubCommands}}
  {{.CommandPath}} [command]{{end}}{{if gt (len .Aliases) 0}}

Aliases:
  {{.NameAndAliases}}{{end}}{{if .HasAvailableSubCommands}}

Available Commands:{{range .Commands}}{{if (or .IsAvailableCommand (eq .Name "help"))}}
  {{rpad .Name .NamePadding }} {{.Short}}{{end}}{{end}}{{end}}{{if .HasAvailableLocalFlags}}

Flags:
{{.LocalFlags.FlagUsages | trimRightSpace}}{{end}}{{if .HasAvailableInheritedFlags}}

Global Flags:
{{.InheritedFlags.FlagUsages | trimRightSpace}}{{end}}{{if .HasHelpSubCommands}}

Additional help topics:{{range .Commands}}{{if .IsAdditionalHelpTopicCommand}}
  {{rpad .Name .NamePadding}} {{.Short}}{{end}}{{end}}{{end}}{{if .HasAvailableSubCommands}}

Use "{{.CommandPath}} [command] --help" for more information about a command.{{end}}
`)
}
