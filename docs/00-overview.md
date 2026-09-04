# Project Overview

## Concept

The project is a desktop shell for Linux Wayland sessions, inspired by the coherence and interaction model of macOS while remaining native to Linux.

It is **not** a desktop environment replacement and does not attempt to reimplement a compositor, display server, authentication system, or core Linux services.

## Primary stack

- QuickShell
- QML
- Wayland
- D-Bus
- PipeWire / WirePlumber
- Linux system APIs
- C++ for backend services and system integration

## Main experience

1. Top menu bar
2. Application dock
3. Application launcher
4. Workspace/window overview
5. Control center
6. Notification center
7. OSD
8. Media controls
9. Wallpaper management
10. Settings
11. Power/session controls

## Design direction

The visual language should feel:

- clean
- calm
- premium
- spatial
- consistent
- responsive

macOS is an inspiration for interaction quality, not a requirement to copy proprietary assets or exact UI.
