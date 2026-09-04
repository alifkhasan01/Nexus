import QtQuick
import "../../theme"
import "../../components"

// WorkspaceThumb — compact workspace card in the overview strip
Item {
    id: root

    property int    workspaceId:   0
    property string workspaceName: ""
    property int    windowCount:   0
    property bool   active:        false

    signal clicked()

    implicitWidth:  110
    implicitHeight: 80

    HoverHandler { id: hov }

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        root.active
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20)
            : (hov.hovered ? Theme.surfaceElevated : Theme.surface)

        border.color: root.active ? Theme.accent : Theme.border
        border.width: root.active ? 2 : 1

        Behavior on color  { ColorAnimation { duration: Theme.durationFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        // Mini window indicators
        Row {
            anchors {
                centerIn: parent
                verticalCenterOffset: -8
            }
            spacing: 4

            Repeater {
                model: Math.min(root.windowCount, 6)
                Rectangle {
                    width:  12; height: 9
                    radius: 2
                    color:  root.active ? Theme.accent : Theme.surfaceHighlight
                    opacity: 0.7
                }
            }
        }

        // Workspace name
        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom:           parent.bottom
                bottomMargin:     Theme.spacingXs
            }
            text:           root.workspaceName
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    root.active ? Theme.weightSemibold : Theme.weightRegular
            color:          root.active ? Theme.accent : Theme.textSecondary
        }
    }

    // Scale feedback
    scale: hov.hovered ? 1.04 : 1.0
    Behavior on scale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
    }

    TapHandler { onTapped: root.clicked() }
    NxTooltip   { text: "Workspace " + root.workspaceName }
}
