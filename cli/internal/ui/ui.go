// Package ui provides simple terminal output helpers.
package ui

import (
	"fmt"
	"os"
	"strings"
)

// ANSI colour codes
const (
	reset  = "\033[0m"
	bold   = "\033[1m"
	dimCol = "\033[2m"

	colorBlue   = "\033[34m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
	colorCyan   = "\033[36m"
	colorGray   = "\033[90m"
)

func isTerminal() bool {
	fi, err := os.Stdout.Stat()
	if err != nil {
		return false
	}
	return (fi.Mode() & os.ModeCharDevice) != 0
}

func color(c, s string) string {
	if !isTerminal() {
		return s
	}
	return c + s + reset
}

// Step prints a blue arrow step message.
func Step(format string, a ...any) {
	fmt.Printf("%s %s\n", color(colorBlue+bold, "→"), fmt.Sprintf(format, a...))
}

// Success prints a green checkmark message.
func Success(format string, a ...any) {
	fmt.Printf("%s %s\n", color(colorGreen+bold, "✓"), fmt.Sprintf(format, a...))
}

// Warn prints a yellow warning message.
func Warn(format string, a ...any) {
	fmt.Printf("%s %s\n", color(colorYellow+bold, "⚠"), fmt.Sprintf(format, a...))
}

// Error prints a red error message to stderr.
func Error(format string, a ...any) {
	fmt.Fprintf(os.Stderr, "%s %s\n", color(colorRed+bold, "✗"), fmt.Sprintf(format, a...))
}

// Info prints a dim informational message.
func Info(format string, a ...any) {
	fmt.Printf("%s %s\n", color(colorGray, "·"), fmt.Sprintf(format, a...))
}

// Header prints a bold section header.
func Header(title string) {
	line := strings.Repeat("─", 48)
	fmt.Printf("\n%s\n  %s\n%s\n", color(colorCyan, line), color(bold, title), color(colorCyan, line))
}

// Label prints a key/value pair.
func Label(key, value string) {
	fmt.Printf("  %-20s %s\n", color(colorGray, key+":"), value)
}

// CheckRow prints a dependency check result row.
func CheckRow(name, version string, found bool) {
	if found {
		fmt.Printf("  %s %-18s %s\n",
			color(colorGreen, "✓"),
			name,
			color(colorGray, version),
		)
	} else {
		fmt.Printf("  %s %-18s %s\n",
			color(colorRed, "✗"),
			name,
			color(colorRed, "not found"),
		)
	}
}
