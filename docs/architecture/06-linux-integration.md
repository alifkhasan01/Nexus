# Linux Integration Layer

This document maps every feature area of the shell to the technology that powers it, distinguishing between what QuickShell handles natively and what requires an external tool, system service, or C++ integration.

---

## What QuickShell handles natively

The following are available out of the box as QuickShell modules — no extra tooling needed.

| Area | QuickShell module |
|---|---|
| Wayland windowing (layer shell, popups, anchors) | `Quickshell` + `Quickshell.Wayland` |
| Workspace management — Hyprland | `Quickshell.Hyprland` |
| Workspace management — i3/Sway | `Quickshell.I3` |
| Audio (PipeWire) | `Quickshell.Services.Pipewire` |
| Bluetooth (BlueZ) | `Quickshell.Bluetooth` |
| Battery / power statistics (UPower) | `Quickshell.Services.UPower` |
| MPRIS media player controls | `Quickshell.Services.Mpris` |
| Notification daemon (freedesktop spec) | `Quickshell.Services.Notifications` |
| System tray (StatusNotifierItem) | `Quickshell.Services.SystemTray` |
| DBus menu (tray context menus) | `Quickshell.DBusMenu` |
| PAM authentication (lock screen) | `Quickshell.Services.Pam` |
| Greetd (display manager / greeter) | `Quickshell.Services.Greetd` |
| Process execution, sockets, file IO | `Quickshell.Io` |

---

## What is NOT handled by QuickShell

Everything below requires an external daemon, system service, or C++ bridge.

---

### 1. Network management

**What's needed:** read Wi-Fi state, list networks, connect/disconnect, airplane mode toggle.

**Solution:** NetworkManager via D-Bus.

- D-Bus service: `org.freedesktop.NetworkManager`
- C++ bridge using `QDBusInterface` or generated proxy from `qdbusxml2cpp`
- No external CLI tool needed — communicate directly over D-Bus

---

### 2. Screen brightness

**What's needed:** read and set display backlight level.

**Solution:** Read/write `/sys/class/backlight/<device>/brightness` directly, or use logind's D-Bus backlight API for unprivileged access.

- D-Bus interface: `org.freedesktop.login1.Session` → `SetBrightness`
- Alternative: `brightnessctl` CLI, called via `Quickshell.Io.Process` if D-Bus is not available
- C++ bridge is preferred for direct sysfs/logind access without spawning a process

---

### 3. Screenshot and screen recording

**What's needed:** capture full screen, region, or window; optionally record screen.

**Solution:** Compositor-native screencopy + external tools.

- Screenshot: `grim` (full screen / output), `slurp` (region selection)
- Screen recording: `wf-recorder` or `gpu-screen-recorder`
- Invoked via `Quickshell.Io.Process`
- For sandboxed apps: `xdg-desktop-portal` with a compositor-specific backend must be running (see §9 below)

---

### 4. Wallpaper

**What's needed:** set per-monitor wallpaper, animate transitions.

**Solution:** Wayland wallpaper daemon.

- Recommended: `awww` (smooth transitions, IPC control, successor to swww)
- Alternative: `mpvpaper`, `swaybg`
- The shell sets the wallpaper by calling the daemon's IPC (e.g. `awww img`) via `Quickshell.Io.Process`
- QuickShell has no built-in wallpaper-setting capability

---

### 5. Power / session actions

**What's needed:** lock screen, logout, suspend, hibernate, reboot, shutdown.

**Solution:** systemd-logind via D-Bus.

- D-Bus service: `org.freedesktop.login1`
- Methods: `Suspend`, `Hibernate`, `Reboot`, `PowerOff`
- Lock: send `Lock` signal or call compositor lock command
- C++ bridge using `QDBusInterface`
- No external CLI needed

---

### 6. Compositor integration beyond Hyprland/Sway

**What's needed:** list windows, switch workspaces, move windows, get active app info — on compositors other than Hyprland/i3/Sway.

**Solution:** Compositor-specific IPC or Wayland protocols.

- Hyprland: QuickShell handles this natively via `Quickshell.Hyprland`
- Niri: IPC socket (JSON), bridged via C++ `QLocalSocket`
- Other compositors: `ext-foreign-toplevel-list-v1` Wayland protocol where available
- This maps to the `CompositorService` abstraction defined in `docs/architecture/04-compositor-abstraction.md`

---

### 7. App launcher / application indexing

**What's needed:** enumerate installed applications, their names, icons, and exec commands.

**Solution:** XDG `.desktop` file parsing.

- Read from `$XDG_DATA_DIRS/applications/` (typically `/usr/share/applications`, `~/.local/share/applications`)
- C++ bridge using `QSettings` or direct file parsing
- Icon resolution: follow XDG icon theme spec, use `QIcon::fromTheme()`
- QuickShell has no built-in app indexer

---

### 8. Polkit (privilege escalation)

**What's needed:** a graphical polkit authentication agent for elevated operations (e.g. package install dialogs, system settings requiring root).

**Solution:** Run a polkit agent alongside the shell.

- Options: `polkit-kde-agent`, `lxqt-policykit`, `polkit-gnome`, or a custom QML agent using `Quickshell.Services.Pam`
- The shell itself does not need to implement this unless a built-in auth dialog is desired
- Required for: NetworkManager connections requiring authentication, some power operations

---

### 9. XDG Desktop Portal

**What's needed:** allow sandboxed apps (Flatpak, Snap) to request screen capture, file pickers, and settings from the compositor environment.

**Solution:** Run an XDG portal backend matching the compositor.

- Hyprland: `xdg-desktop-portal-hyprland`
- wlroots-based: `xdg-desktop-portal-wlr`
- Generic: `xdg-desktop-portal-gtk` (file picker fallback)
- The shell does not implement the portal — it is a separate daemon that must be running

---

### 10. Idle and lock screen

**What's needed:** detect user idle, dim/lock after timeout.

**Solution:** idle protocol + lock screen protocol.

- Idle detection: `ext-idle-notify-v1` Wayland protocol (compositor must support it)
- Lock screen: `ext-session-lock-v1` protocol, implemented via `Quickshell.Services.Pam` for auth
- Idle daemon options: `hypridle`, `swayidle`
- The shell can implement the lock screen UI directly using QuickShell; idle management typically delegates to `hypridle`/`swayidle`

---

### 11. Night light / color temperature

**What's needed:** reduce blue light at night by shifting display color temperature.

**Solution:** Wayland color management or external tool.

- Wayland protocol: `wlr-gamma-control-unstable-v1` (wlroots) or compositor-native APIs
- External tool: `gammastep`, `hyprsunset`, `wlsunset`
- Called via `Quickshell.Io.Process` or configured as a separate daemon

---

### 12. Clipboard management

**What's needed:** clipboard history, cross-app paste.

**Solution:** Wayland clipboard daemon.

- Options: `cliphist`, `wl-clipboard`
- The shell can display clipboard history by reading from the daemon's store
- Wayland does not expose clipboard contents unless the window has focus; a dedicated clipboard manager daemon is required

---

## Summary table

| Feature | QuickShell native | External requirement |
|---|---|---|
| Wayland windowing | ✓ | — |
| Hyprland workspace/window | ✓ | — |
| Sway/i3 workspace | ✓ | — |
| Audio (PipeWire) | ✓ | — |
| Bluetooth | ✓ | BlueZ running |
| Battery | ✓ | UPower running |
| MPRIS media | ✓ | MPRIS-compatible player |
| Notifications | ✓ | — |
| System tray | ✓ | — |
| PAM auth / lock screen | ✓ | PAM configured |
| Network | — | NetworkManager + D-Bus bridge |
| Brightness | — | logind D-Bus or sysfs bridge |
| Screenshot | — | `grim`, `slurp` |
| Screen recording | — | `wf-recorder` / `gpu-screen-recorder` |
| Wallpaper | — | `awww` or equivalent |
| Power actions | — | logind D-Bus bridge |
| Non-Hyprland compositor | — | Protocol/IPC bridge |
| App indexing | — | XDG `.desktop` parser (C++) |
| Polkit agent | — | `polkit-kde-agent` or custom |
| XDG portal | — | `xdg-desktop-portal-hyprland` etc. |
| Idle management | — | `hypridle` / `swayidle` |
| Night light | — | `gammastep` / `hyprsunset` |
| Clipboard history | — | `cliphist` + `wl-clipboard` |

---

## Runtime dependencies

The following must be installed and running for the full shell experience.

### System daemons (always required)

- `pipewire` + `wireplumber` — audio
- `bluez` — Bluetooth
- `upower` — battery
- `networkmanager` — network
- `systemd-logind` (or `elogind`) — session/power management

### Wayland tools (installed, invoked on demand)

- `grim` — screenshot
- `slurp` — region selection
- `awww` — wallpaper
- `wf-recorder` or `gpu-screen-recorder` — screen recording

### Recommended companions

- `hypridle` or `swayidle` — idle/lock trigger
- `xdg-desktop-portal` + compositor backend — portal support for sandboxed apps
- `polkit-kde-agent` or equivalent — privilege escalation dialogs
- `cliphist` + `wl-clipboard` — clipboard history

### C++ / Qt build dependencies

- Qt 6 (QtQuick, QtDBus, QtWidgets optional)
- CMake ≥ 3.16
- GCC ≥ 12 or Clang ≥ 15
