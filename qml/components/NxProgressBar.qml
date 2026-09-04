import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxProgressBar — determinate and indeterminate progress
Controls.ProgressBar {
    id: root

    property color  trackColor:  Theme.border
    property color  fillColor:   Theme.accent
    property int    barHeight:   6

    implicitWidth:  200
    implicitHeight: barHeight

    // ── Background ──────────────────────────────────────────
    background: Rectangle {
        anchors.fill: parent
        radius: root.barHeight / 2
        color:  root.trackColor
        clip:   true

        // Indeterminate shimmer
        Rectangle {
            id: indeterminate
            visible: root.indeterminate
            width:  parent.width * 0.35
            height: parent.height
            radius: root.barHeight / 2
            color:  root.fillColor

            SequentialAnimation on x {
                running:  root.indeterminate
                loops:    Animation.Infinite
                NumberAnimation {
                    from: -indeterminate.width
                    to:    parent.width
                    duration: 900
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // ── Fill ─────────────────────────────────────────────────
    contentItem: Item {
        visible: !root.indeterminate

        Rectangle {
            width:  root.visualPosition * parent.width
            height: parent.height
            radius: root.barHeight / 2
            color:  root.fillColor
            clip:   false

            Behavior on width {
                enabled: !Theme.reducedMotion
                NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
            }
        }
    }
}
