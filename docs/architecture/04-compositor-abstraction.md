# Compositor Abstraction

The shell should avoid coupling every UI component directly to Hyprland IPC.

## Interface concept

```text
CompositorService
├── HyprlandBackend
├── NiriBackend
└── SwayBackend
```

Common operations may include:

- listWorkspaces()
- activeWorkspace()
- listWindows()
- focusWindow()
- closeWindow()
- moveWindow()
- switchWorkspace()
- moveWindowToWorkspace()

Only compositor-specific behavior belongs in the backend implementation.
