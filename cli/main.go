package main

import (
	"os"

	"github.com/nexus-shell/nexus/cli/cmd"
	"github.com/nexus-shell/nexus/cli/internal/ui"
)

func main() {
	if err := cmd.Execute(); err != nil {
		ui.Error("%v", err)
		os.Exit(1)
	}
}
