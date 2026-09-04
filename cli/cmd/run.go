package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	"github.com/alifkhansen01/Nexus/cli/internal/project"
	"github.com/alifkhansen01/Nexus/cli/internal/ui"
	"github.com/spf13/cobra"
)

var runCmd = &cobra.Command{
	Use:   "run",
	Short: "Run the compiled Nexus shell",
	Long: `Execute the Nexus binary from build/.

If the binary is not found, run 'nexus build' first.
Any extra arguments after -- are forwarded to the binary.`,
	RunE:               runRun,
	DisableFlagParsing: false,
}

var runArgs []string

func init() {
	runCmd.Flags().StringArrayVar(&runArgs, "args", nil, "Extra arguments forwarded to the nexus binary")
	rootCmd.AddCommand(runCmd)
}

func runRun(_ *cobra.Command, extraArgs []string) error {
	root, err := project.Root()
	if err != nil {
		return err
	}

	binary := project.BinaryPath(root)
	if !project.Exists(binary) {
		return fmt.Errorf("binary not found at %s — run 'nexus build' first", binary)
	}

	// Merge --args flag and positional extra args
	allArgs := append(runArgs, extraArgs...)

	ui.Header("Running Nexus")
	ui.Label("Binary", binary)
	if len(allArgs) > 0 {
		ui.Label("Args", fmt.Sprintf("%v", allArgs))
	}
	fmt.Println()
	ui.Info("Press Ctrl+C to stop")
	fmt.Println()

	cmd := exec.Command(binary, allArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Dir = root

	// Forward SIGINT/SIGTERM to child
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start nexus: %w", err)
	}

	go func() {
		sig := <-sigs
		if cmd.Process != nil {
			_ = cmd.Process.Signal(sig)
		}
	}()

	err = cmd.Wait()
	signal.Stop(sigs)

	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			code := exitErr.ExitCode()
			if code == -1 {
				// Killed by signal — normal on Ctrl+C
				ui.Info("nexus stopped")
				return nil
			}
			return fmt.Errorf("nexus exited with code %d", code)
		}
		return err
	}

	ui.Info("nexus exited cleanly")
	return nil
}
