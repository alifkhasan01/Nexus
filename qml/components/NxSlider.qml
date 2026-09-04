import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxSlider — horizontal range slider
Controls.Slider {
    id: root

    property color  trackColor:  Theme.border
    property color  fillColor:   Theme.accent
    property color  handleColor: "#ffffff"
    property int    trackHeight: 4
    property int    handleSize:  18

    implicitWidth:  200
    implicitHeight: handleSize

    // ── Track background ─────────────────────────────────────
    background: Item {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - trackHeight) / 2
        width:  root.availableWidth
        height: trackHeight

        // inactive portion
        Rectangle {
            anchors.fill: parent
            radius: trackHeight / 2
            color:  root.trackColor
        }

        // active (filled) portion
        Rectangle {
            width:  root.visualPosition * parent.width
            height: parent.height
            radius: trackHeight / 2
            color:  root.fillColor
            Behavior on width {
                enabled: !Theme.reducedMotion
                NumberAnimation { duration: Theme.durationFast }
            }
        }
    }

    // ── Handle ───────────────────────────────────────────────
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding  + (root.availableHeight - height) / 2
        width:  root.handleSize
        height: root.handleSize
        radius: root.handleSize / 2
        color:  root.handleColor

        scale: root.pressed ? 0.85 : 1.0
        Behavior on scale {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationFast }
        }

        // Focus ring
        Rectangle {
            anchors.fill:    parent
            anchors.margins: -3
            radius:          (root.handleSize + 6) / 2
            color:           "transparent"
            border.color:    Theme.borderFocus
            border.width:    2
            visible:         root.activeFocus
        }

        layer.enabled: true
        layer.effect: null   // drop shadow can be added by consumers
    }
}
