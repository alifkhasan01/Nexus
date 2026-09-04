import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// Bar — top status/menu bar, one instance per monitor
//
// Anchored to the top edge via Wayland layer-shell.
// Left:   workspace indicators + active app label
// Center: clock
// Right:  status icons + tray + action buttons
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    // ── Inputs from shell.qml ────────────────────────────────
    required property var  screen
    property bool launcherOpen:      false
    property bool controlCenterOpen: false
    property bool notifCenterOpen:   false

    signal toggleLauncher()
    signal toggleControlCenter()
    signal toggleNotifCenter()

    // ── Layer-shell positioning ──────────────────────────────
    WlrLayershell.layer:       WlrLayer.Top
    WlrLayershell.exclusiveZone: Theme.barHeight
    WlrLayershell.anchors:     WlrAnchors { top: true; left: true; right: true }
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.None

    implicitWidth:  screen.width
    implicitHeight: Theme.barHeight
    color: "transparent"

    // ── Background ──────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.background
        opacity:      0.90

        // Bottom border line
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            color:  Theme.border
            opacity: 0.5
        }
    }

    // ── Layout ───────────────────────────────────────────────
    RowLayout {
        anchors {
            fill:           parent
            leftMargin:     Theme.spacingMd
            rightMargin:    Theme.spacingMd
        }
        spacing: 0

        // LEFT — workspaces + active app
        RowLayout {
            spacing: Theme.spacingSm

            WorkspaceIndicator {}

            NxSeparator {
                vertical:  true
                implicitHeight: 16
                opacity:   0.5
            }

            ActiveAppLabel {}
        }

        // SPACER
        Item { Layout.fillWidth: true }

        // CENTER — clock
        Clock {}

        // SPACER
        Item { Layout.fillWidth: true }

        // RIGHT — status + tray + buttons
        RowLayout {
            spacing: Theme.spacingXs

            SysTray {}

            NxSeparator {
                vertical: true
                implicitHeight: 16
                opacity: 0.4
            }

            StatusIcons {
                onTriggerControlCenter: root.toggleControlCenter()
            }

            NxSeparator {
                vertical: true
                implicitHeight: 16
                opacity: 0.4
            }

            // Notification bell
            BarButton {
                iconName: root.notifCenterOpen ? "notification-symbolic" : "notification-new-symbolic"
                active:   root.notifCenterOpen
                onClicked: root.toggleNotifCenter()

                NxTooltip { text: "Notifications" }
            }
        }
    }
}
