# Nexus

A modern, modular Wayland desktop shell for Linux — inspired by the coherence of macOS, built on top of your existing system.

Built with [QuickShell](https://quickshell.outfoxxed.me/), QML, and a C++ backend for deep system integration.

> **Status:** Early development — not ready for daily use.

---

## Overview

Nexus sits on top of your Wayland compositor (Hyprland, Niri, Sway, etc.) and provides:

- Top bar with workspace indicator, active app label, clock, and status icons
- Dock with running app indicators and auto-hide
- App launcher with fuzzy search
- Workspace overview (Mission Control-style)
- Control center with quick toggles
- Notification center
- On-screen display (OSD) for volume, brightness
- Media player controls (MPRIS)
- Wallpaper picker
- Settings panel

---

## Requirements

**Build dependencies:**

| Tool | Version | Purpose |
|---|---|---|
| CMake | ≥ 3.16 | Build system |
| GCC or Clang | GCC ≥ 12 / Clang ≥ 15 | C++ compiler |
| Qt6 | ≥ 6.5 | Core framework |
| Qt6 DBus | same | D-Bus integration |
| pkg-config | any | Library detection |
| Ninja | any (optional) | Faster builds |
| Go | ≥ 1.21 | CLI tool (`nexus`) |

**Runtime dependencies:**

| Tool | Purpose |
|---|---|
| QuickShell | QML shell runtime |
| PipeWire + WirePlumber | Audio |
| BlueZ | Bluetooth |
| UPower | Battery |
| NetworkManager | Network |
| systemd-logind or elogind | Power/session |

**Optional tools** (for full functionality):

| Tool | Purpose |
|---|---|
| `awww` | Wallpaper daemon |
| `grim` + `slurp` | Screenshots |
| `wf-recorder` | Screen recording |

---

## Installing the CLI

The `nexus` CLI handles building, running, and watching the project. Install it once, then use it for everything.

**Via `go install` (recommended):**

```bash
go install github.com/alifkhasan01/Nexus/cli/cmd/nexus@latest
```

The binary is placed in `$GOPATH/bin` (usually `~/go/bin`). Make sure that directory is in your `$PATH`:

```bash
export PATH="$HOME/go/bin:$PATH"
```

**From source:**

```bash
git clone https://github.com/alifkhansen01/Nexus.git
cd Nexus/cli
go build -o nexus ./cmd/nexus/
sudo mv nexus /usr/local/bin/
```

**Verify:**

```bash
nexus --help
```

**Check your system dependencies:**

```bash
nexus check
```

This probes for cmake, Qt6, compiler, QuickShell, awww, grim, and other tools — validates minimum versions and tells you what's missing.

---

## Building

```bash
# Debug build (default)
nexus build

# Release build
nexus build --release

# Control parallel jobs
nexus build -j4

# Verbose output
nexus build --verbose
```

The first run configures CMake automatically. Subsequent runs skip the configure step unless the build directory is missing.

**Manual CMake** (if you prefer not to use the CLI):

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --parallel
```

---

## Development Workflow

`nexus dev` is the main command for day-to-day development. It builds the project, launches it, and watches for file changes:

```bash
nexus dev
```

**What it does:**

- Builds the project (Debug)
- Launches `./build/nexus`
- Watches `qml/` and `src/` for changes
- `.qml` file changed → sends `SIGUSR1` to the running process (QuickShell hot-reloads QML in-place, no restart)
- `.cpp` / `.h` file changed → rebuilds and restarts the process automatically

**Options:**

```bash
nexus dev --skip-build        # skip initial build, just run + watch
nexus dev --no-watch          # run without file watcher
nexus dev --debounce 500      # wait 500ms before reacting to changes (default: 300ms)
nexus dev --release           # build with Release type instead of Debug
nexus dev -j4                 # limit parallel compile jobs
nexus dev --verbose           # show full compiler output during rebuilds
```

---

## Running

```bash
# Run from build directory
nexus run

# Pass extra arguments to the nexus binary
nexus run --args "--some-flag"
```

---

## Cleaning

```bash
nexus clean          # prompts for confirmation
nexus clean --force  # skip confirmation
```

This removes the `build/` directory entirely, forcing a full reconfigure on the next build.

---

## CLI Reference

| Command | Description |
|---|---|
| `nexus check` | Check all build and runtime dependencies |
| `nexus build` | Configure (if needed) and compile |
| `nexus build --release` | Optimised release build |
| `nexus build -j N` | Build with N parallel jobs |
| `nexus build --verbose` | Show full compiler output |
| `nexus build --no-configure` | Skip cmake configure step |
| `nexus dev` | Build + run + hot-reload watcher |
| `nexus dev --skip-build` | Skip initial build step |
| `nexus dev --no-watch` | Run without file watcher |
| `nexus dev --release` | Dev loop with Release build type |
| `nexus dev -j N` | Limit parallel jobs during rebuilds |
| `nexus dev --verbose` | Verbose output during rebuilds |
| `nexus run` | Launch the compiled shell |
| `nexus install` | Install binary to `~/.local/bin` |
| `nexus install --prefix /usr` | Install to a custom prefix |
| `nexus install --copy-only` | Copy binary only, skip cmake --install |
| `nexus clean` | Remove build directory |
| `nexus clean --force` | Remove without confirmation |

---

## Project Structure

```
nexus/
├── cli/                  # Developer CLI (Go)
│   ├── cmd/
│   │   ├── nexus/        # Entry point — go install lands here
│   │   └── *.go          # CLI commands (build, dev, run, check, clean, install)
│   └── internal/         # Shared helpers (ui, runner, project, build)
├── src/                  # C++ backend
│   ├── services/         # AudioService, BatteryService, NetworkService, …
│   ├── compositor/       # CompositorService + Hyprland backend
│   └── appindexer/       # XDG .desktop app indexing
├── qml/
│   ├── theme/            # Shared design tokens (Theme.qml)
│   ├── components/       # Reusable components (NxButton, NxSlider, …)
│   └── modules/
│       ├── bar/          # Top bar
│       ├── dock/         # Application dock
│       ├── launcher/     # App launcher
│       ├── overview/     # Workspace overview
│       ├── control-center/
│       ├── notifications/
│       ├── osd/          # On-screen display
│       ├── media/        # MPRIS media player
│       ├── wallpaper/    # Wallpaper picker
│       └── settings/     # Settings panel
├── docs/                 # Architecture, design, and module docs
└── CMakeLists.txt
```

---

## Documentation

- [`docs/00-overview.md`](docs/00-overview.md) — project overview
- [`docs/01-vision.md`](docs/01-vision.md) — vision and principles
- [`docs/architecture/`](docs/architecture/) — system, module, and service architecture
- [`docs/design/`](docs/design/) — design system (colours, typography, spacing, animation)
- [`docs/modules/`](docs/modules/) — per-module documentation
- [`docs/services/`](docs/services/) — system service contracts
- [`docs/development/`](docs/development/) — coding style, C++ guidelines, QML guidelines, git workflow
- [`docs/roadmap.md`](docs/roadmap.md) — development roadmap

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

The short version:
- Read the relevant architecture doc before making changes
- Keep module boundaries intact — modules don't import from each other
- QML handles UI only; system logic belongs in C++ services
- Match the existing code style
