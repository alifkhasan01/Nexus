import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxIconButton — square icon-only button
Controls.AbstractButton {
    id: root

    property string iconName:   ""
    property int    iconSize:   Theme.iconMd
    property int    buttonSize: iconSize + Theme.spacingMd * 2

    property bool  subtle:  false   // lighter hover bg
    property color tintColor: Theme.text

    implicitWidth:  buttonSize
    implicitHeight: buttonSize

    // ── Background ──────────────────────────────────────────
    background: Rectangle {
        radius: Theme.radiusSm
        color: {
            if (!root.enabled)     return "transparent"
            if (root.pressed)      return root.subtle ? Theme.border : Theme.surfaceHighlight
            if (root.hovered)      return root.subtle ? Theme.surfaceHighlight : Theme.surfaceElevated
            return "transparent"
        }
        Behavior on color {
            enabled: !Theme.reducedMotion
            ColorAnimation { duration: Theme.durationFast }
        }
    }

    // ── Icon ────────────────────────────────────────────────
    contentItem: Item {
        // Source icon via image; caller sets iconName to an icon path
        Image {
            anchors.centerIn: parent
            width:  root.iconSize
            height: root.iconSize
            source: root.iconName
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: root.iconName !== ""
            // Colorize monochrome icons
            layer.enabled: root.tintColor !== Theme.text
            layer.effect: null   // ShaderEffect colorize can be added by consumer
        }
    }

    // ── Focus ring ───────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: Theme.radiusSm + 2
        color: "transparent"
        border.color: Theme.borderFocus
        border.width: 2
        visible: root.activeFocus
    }

    scale: root.pressed ? 0.90 : 1.0
    Behavior on scale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast }
    }
}
