import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "theme"
import "modules/bar"
import "modules/dock"
import "modules/launcher"
import "modules/overview"
import "modules/osd"
import "modules/notifications"

// ─────────────────────────────────────────────────────────────
// shell.qml — Root entry point
//
// Responsibilities:
//   - Create a ShellRoot per-screen via Variants
//   - Wire global keyboard shortcuts
//   - Manage which overlays (launcher, overview, CC, etc.) are open
//   - Route OSD triggers from services
// ─────────────────────────────────────────────────────────────
ShellRoot {
    id: root

    // ── Global overlay state ─────────────────────────────────
    // Only one exclusive overlay open at a time.
    QtObject {
        id: shell

        property bool launcherOpen:     false
        property bool overviewOpen:     false
        property bool controlCenterOpen: false
        property bool notifCenterOpen:  false
        property bool settingsOpen:     false

        // Close everything
        function closeAll() {
            launcherOpen     = false
            overviewOpen     = false
            controlCenterOpen = false
            notifCenterOpen  = false
            settingsOpen     = false
        }

        function toggleLauncher()     { closeAll(); launcherOpen     = !launcherOpen     }
        function toggleOverview()     { closeAll(); overviewOpen     = !overviewOpen     }
        function toggleControlCenter(){ closeAll(); controlCenterOpen = !controlCenterOpen }
        function toggleNotifCenter()  { closeAll(); notifCenterOpen  = !notifCenterOpen  }
    }

    // ── OSD state ────────────────────────────────────────────
    QtObject {
        id: osdState
        property string type:  ""   // "volume" | "brightness" | "mic"
        property real   value: 0.0  // 0..1
        property bool   muted: false
        property bool   visible: false

        function show(t, v, m) {
            type    = t
            value   = v
            muted   = m
            visible = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 2200
        onTriggered: osdState.visible = false
    }

    // Watch AudioService for OSD triggers
    Connections {
        target: AudioService
        function onVolumeChanged()    { osdState.show("volume",     AudioService.volume / 100.0, AudioService.muted) }
        function onMutedChanged()     { osdState.show("volume",     AudioService.volume / 100.0, AudioService.muted) }
        function onMicMutedChanged()  { osdState.show("mic",        AudioService.micVolume / 100.0, AudioService.micMuted) }
    }
    Connections {
        target: BrightnessService
        function onBrightnessChanged(){ osdState.show("brightness", BrightnessService.percent, false) }
    }

    // ── Global keyboard shortcuts (Wayland layer-shell focus) ─
    // These work because the bar/launcher panels request keyboard interactivity.
    Shortcut {
        sequences: ["Meta+Space", "Meta+D"]
        onActivated: shell.toggleLauncher()
    }
    Shortcut {
        sequence: "Meta+Tab"
        onActivated: shell.toggleOverview()
    }
    Shortcut {
        sequence: "Escape"
        onActivated: shell.closeAll()
    }

    // ── Per-monitor shell surfaces ───────────────────────────
    // Variants creates one instance per screen automatically.
    Variants {
        model: Quickshell.screens

        // Each variant gets a `modelData` property = the screen object
        Bar {
            screen:              modelData
            launcherOpen:        shell.launcherOpen
            controlCenterOpen:   shell.controlCenterOpen
            notifCenterOpen:     shell.notifCenterOpen
            onToggleLauncher:     shell.toggleLauncher()
            onToggleControlCenter: shell.toggleControlCenter()
            onToggleNotifCenter:  shell.toggleNotifCenter()
        }

        Dock {
            screen: modelData
        }

        Osd {
            screen:  modelData
            type:    osdState.type
            value:   osdState.value
            muted:   osdState.muted
            visible: osdState.visible
        }
    }

    // ── Single-instance overlays (primary screen only) ───────
    Launcher {
        screen:  Quickshell.screens[0]
        visible: shell.launcherOpen
        onClose: shell.launcherOpen = false
    }

    Overview {
        screen:  Quickshell.screens[0]
        visible: shell.overviewOpen
        onClose: shell.overviewOpen = false
    }

    // Notification banners (per-screen handled inside the component)
    NotificationBannerLayer {
        screen: Quickshell.screens[0]
    }
}
