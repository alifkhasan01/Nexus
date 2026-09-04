# Security

The shell runs with the user's desktop privileges and should be conservative with system operations.

## Rules

- Never collect credentials.
- Never implement password handling in the shell.
- Avoid arbitrary command execution from untrusted input.
- Validate paths and user-provided configuration.
- Do not expose unnecessary D-Bus/system capabilities.
- Prefer established system APIs.
