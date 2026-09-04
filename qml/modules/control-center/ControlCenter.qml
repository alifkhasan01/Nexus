import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// ControlCenter — slide-down panel from top-right corner
//
// Sections:
//   Quick tiles: wifi, bluetooth, airplane, night-light, idle-inhibit
//   Sliders:     volume, mic, brightness
//   Battery info
//   Media card
//   Power row
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var  screen
    property bool          visible: false
    signal close()

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.OnDemand
    WlrLayershell.anchors: WlrAnchors { top: true; right: true }

    implicitWidth:  360
    implicitHeight: screen.height   // oversized; clip via panel rectangle
    color: "transparent"

    // Panel slides in from top-right
    property int panelY: Theme.barHeight + Theme.spacingSm

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
    }

    // Scrim (outside panel)
    Rectangle {
        anchors.fill: parent
        color:        "transparent"
        TapHandler { onTapped: root.close() }
    }

    // ── Panel ────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            top:   parent.top
            right: parent.right
            topMargin:   root.panelY
            rightMargin: Theme.spacingSm
        }
        width:   360
        radius:  Theme.radiusXl
        color:   Theme.surface
        opacity: Theme.glassOpacity + 0.05
        border.color: Theme.border
        border.width: 1
        clip: true

        // Dynamic height from content
        height: Math.min(contentCol.implicitHeight + Theme.spacingLg * 2,
                         root.screen.height - root.panelY - Theme.spacingLg)

        // Slide-down animation
        transform: Translate {
            y: root.visible ? 0 : -20
            Behavior on y {
                enabled: !Theme.reducedMotion
                NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
            }
        }

        // Top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Theme.borderSubtle; radius: parent.radius
        }

        NxScrollView {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            contentHeight: contentCol.implicitHeight

            Column {
                id: contentCol
                width:   panel.width - Theme.spacingLg * 2
                spacing: Theme.spacingLg

                // ── Quick tiles ──────────────────────────────
                GridLayout {
                    width:   parent.width
                    columns: 2
                    rowSpacing:    Theme.spacingSm
                    columnSpacing: Theme.spacingSm

                    ControlTile {
                        label:   "Wi-Fi"
                        icon:    NetworkService.wifiEnabled
                            ? "network-wireless" : "network-wireless-disabled"
                        active:  NetworkService.wifiEnabled
                        subtitle: NetworkService.connected ? NetworkService.connectedSsid : "Off"
                        onToggled: NetworkService.wifiEnabled = !NetworkService.wifiEnabled
                    }

                    ControlTile {
                        label:   "Bluetooth"
                        icon:    BluetoothService.powered ? "bluetooth-active" : "bluetooth-disabled"
                        active:  BluetoothService.powered
                        subtitle: BluetoothService.powered ? "On" : "Off"
                        onToggled: BluetoothService.powered = !BluetoothService.powered
                    }

                    ControlTile {
                        label:    "Airplane"
                        icon:     "airplane-mode"
                        active:   NetworkService.airplaneMode
                        subtitle: NetworkService.airplaneMode ? "On" : "Off"
                        onToggled: NetworkService.airplaneMode = !NetworkService.airplaneMode
                    }

                    ControlTile {
                        label:    "Screenshot"
                        icon:     "screenshot"
                        active:   false
                        subtitle: "Capture"
                        onToggled: ScreenshotService.captureFullScreen()
                    }
                }

                NxSeparator { width: parent.width }

                // ── Volume ───────────────────────────────────
                AudioControls { width: parent.width }

                // ── Brightness ───────────────────────────────
                BrightnessControl { width: parent.width }

                NxSeparator { width: parent.width }

                // ── Battery ──────────────────────────────────
                BatteryInfo {
                    width: parent.width
                    visible: BatteryService.present
                }

                NxSeparator { width: parent.width; visible: BatteryService.present }

                // ── Media ────────────────────────────────────
                MediaCard { width: parent.width }

                NxSeparator { width: parent.width }

                // ── Network details ──────────────────────────
                NetworkControls { width: parent.width }

                NxSeparator { width: parent.width }

                // ── Power actions ────────────────────────────
                Row {
                    width:   parent.width
                    spacing: Theme.spacingSm

                    Repeater {
                        model: [
                            { label: "Lock",      icon: "system-lock-screen",  action: function(){ PowerService.lock()     }},
                            { label: "Suspend",   icon: "system-suspend",      action: function(){ PowerService.suspend()  }},
                            { label: "Reboot",    icon: "system-reboot",       action: function(){ PowerService.reboot()   }},
                            { label: "Shutdown",  icon: "system-shutdown",     action: function(){ PowerService.shutdown() }},
                        ]

                        delegate: NxButton {
                            property var btn: modelData
                            text:    btn.label
                            variant: btn.label === "Shutdown"
                                ? NxButton.Variant.Destructive : NxButton.Variant.Secondary
                            Layout.fillWidth: true
                            onClicked: btn.action()
                        }
                    }
                }
            }
        }
    }
}
