import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxToggle — on/off switch
Controls.Switch {
    id: root

    property color  trackOnColor:  Theme.accent
    property color  trackOffColor: Theme.border
    property int    trackWidth:    42
    property int    trackHeight:   24
    property int    thumbSize:     18

    implicitWidth:  trackWidth
    implicitHeight: trackHeight

    // ── Indicator (track + thumb) ────────────────────────────
    indicator: Item {
        implicitWidth:  root.trackWidth
        implicitHeight: root.trackHeight

        // Track
        Rectangle {
            id: track
            anchors.fill: parent
            radius: height / 2
            color:  root.checked ? root.trackOnColor : root.trackOffColor

            Behavior on color {
                enabled: !Theme.reducedMotion
                ColorAnimation { duration: Theme.durationNormal }
            }
        }

        // Thumb
        Rectangle {
            id: thumb
            width:  root.thumbSize
            height: root.thumbSize
            radius: root.thumbSize / 2
            color:  "#ffffff"
            anchors.verticalCenter: track.verticalCenter
            x: root.checked
                ? track.width - width - (root.trackHeight - root.thumbSize) / 2
                : (root.trackHeight - root.thumbSize) / 2

            Behavior on x {
                enabled: !Theme.reducedMotion
                NumberAnimation {
                    duration: Theme.durationNormal
                    easing.type: Theme.easingDecelerate
                }
            }

            scale: root.pressed ? 0.9 : 1.0
            Behavior on scale {
                enabled: !Theme.reducedMotion
                NumberAnimation { duration: Theme.durationFast }
            }
        }
    }

    // No visible label/content from Controls.Switch
    contentItem: null

    // ── Focus ring ───────────────────────────────────────────
    Rectangle {
        anchors.fill:    indicator
        anchors.margins: -3
        radius:          (root.trackHeight + 6) / 2
        color:           "transparent"
        border.color:    Theme.borderFocus
        border.width:    2
        visible:         root.activeFocus
    }
}
