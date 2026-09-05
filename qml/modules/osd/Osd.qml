import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme"

// ─────────────────────────────────────────────────────────────
// Osd — on-screen display for volume / brightness / mic
//
// Centered at the bottom of the screen, above the dock.
// Fades in immediately on change; auto-hides after 2.2s.
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var    screen
    required property string type    // "volume" | "brightness" | "mic"
    required property real   value   // 0.0–1.0 (or 0–1.5 for volume up to 150%)
    required property bool   muted
    property bool            visible: false

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.None
    WlrLayershell.anchors: WlrAnchors { bottom: true; left: true; right: true }

    implicitWidth:  screen.width
    implicitHeight: 80
    color: "transparent"

    opacity: root.visible ? 1.0 : 0.0
    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingStandard }
    }

    OsdBar {
        anchors {
            bottom:           parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin:     72   // above dock
        }
        osdType:  root.type
        osdValue: root.value
        osdMuted: root.muted
    }
}
