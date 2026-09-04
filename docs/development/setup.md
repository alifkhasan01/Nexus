# Development Setup

## Recommended environment

- Linux
- Wayland session
- QuickShell
- QML tooling (Qt 6, Qt Creator or preferred editor)
- C++ toolchain: GCC or Clang, CMake, Qt 6 development headers
- Git

## Development principles

Run the shell from a development session first. Avoid replacing the user's primary desktop session until the feature is stable.

Keep system integrations optional where possible so UI work can be developed independently of the C++ backend.
