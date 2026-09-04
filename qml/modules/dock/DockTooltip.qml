import QtQuick
import "../../theme"

// DockTooltip — label yang muncul di atas dock item saat hover
//
// Penggunaan:
//   DockTooltip {
//       text:    root.appId
//       visible: hov.hovered
//   }
Item {
    id: root

    property string text:    ""
    property bool   visible: false

    // Posisi: di atas parent, centered
    anchors {
        bottom:           parent ? parent.top : undefined
        horizontalCenter: parent ? parent.horizontalCenter : undefined
        bottomMargin:     Theme.spacingXs
    }

    implicitWidth:  label.implicitWidth + Theme.spacingMd * 2
    implicitHeight: label.implicitHeight + Theme.spacingSm

    opacity: root.visible ? 1.0 : 0.0
    scale:   root.visible ? 1.0 : 0.90

    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
    }
    Behavior on scale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
    }

    // Tooltip bubble
    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusSm
        color:        Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1

        // Subtle top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color:  Theme.borderSubtle
            radius: parent.radius
        }

        Text {
            id: label
            anchors.centerIn: parent
            text:           root.text
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightMedium
            color:          Theme.text
        }
    }

    // Caret / arrow pointing down toward the dock icon
    Rectangle {
        anchors {
            top:              parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width:  8
        height: 8
        color:  Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1

        // Mask top border (blended with bubble)
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            color:  Theme.surfaceElevated
        }

        rotation: 45
        transformOrigin: Item.Center
    }

    // Don't consume mouse events
    enabled: false
    z:       999
}
