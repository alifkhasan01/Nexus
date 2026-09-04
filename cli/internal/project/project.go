// Package project resolves paths relative to the Nexus project root.
package project

import (
	"fmt"
	"os"
	"path/filepath"
)

// Root walks up from cwd looking for CMakeLists.txt to find the project root.
// Returns an error if not found within 8 levels.
func Root() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for i := 0; i < 8; i++ {
		if _, err := os.Stat(filepath.Join(dir, "CMakeLists.txt")); err == nil {
			// Extra sanity: must also have qml/ to be the right project
			if _, err := os.Stat(filepath.Join(dir, "qml")); err == nil {
				return dir, nil
			}
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}
	return "", fmt.Errorf("could not find Nexus project root (no CMakeLists.txt + qml/ found)")
}

// BuildDir returns the path to the cmake build directory.
func BuildDir(root string) string {
	return filepath.Join(root, "build")
}

// BinaryPath returns the expected path of the compiled nexus binary.
func BinaryPath(root string) string {
	return filepath.Join(BuildDir(root), "nexus")
}

// QmlDir returns the path to the QML sources.
func QmlDir(root string) string {
	return filepath.Join(root, "qml")
}

// Exists returns true if path exists.
func Exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}
