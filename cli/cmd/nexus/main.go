package main

import (
	"errors"
	"os"

	"github.com/alifkhansen01/Nexus/cli/cmd"
	"github.com/alifkhansen01/Nexus/cli/internal/ui"
)

func main() {
	if err := cmd.Execute(); err != nil {
		// Only print when the subcommand hasn't already shown the error.
		var silent cmd.SilentError
		if !errors.As(err, &silent) {
			ui.Error("%v", err)
		}
		os.Exit(1)
	}
}
