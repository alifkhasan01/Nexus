// Package runner executes shell commands with live output streaming.
package runner

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

// Run executes a command, streaming stdout/stderr to the terminal.
// Returns an error if the command exits non-zero.
func Run(dir string, name string, args ...string) error {
	return RunWithEnv(dir, nil, name, args...)
}

// RunWithEnv executes a command with additional environment variables appended
// to the current process environment.
func RunWithEnv(dir string, extraEnv []string, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if len(extraEnv) > 0 {
		cmd.Env = append(os.Environ(), extraEnv...)
	}

	return cmd.Run()
}

// Output executes a command and returns its combined stdout output as a string.
// Stderr is discarded. Useful for version probing.
func Output(name string, args ...string) (string, error) {
	out, err := exec.Command(name, args...).Output()
	return strings.TrimSpace(string(out)), err
}

// Start starts a command in the background and returns the *exec.Cmd so the
// caller can Wait() or Kill() it.
func Start(dir string, stdout, stderr io.Writer, name string, args ...string) (*exec.Cmd, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout = stdout
	cmd.Stderr = stderr
	cmd.Stdin = nil

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("failed to start %s: %w", name, err)
	}
	return cmd, nil
}

// Which returns true if a binary exists in PATH.
func Which(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}
