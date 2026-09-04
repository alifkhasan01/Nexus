import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"

// WorkspaceIndicator — row of workspace pills
Item {
    id: root

    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs

        Repeater {
            model: CompositorService.workspaces

            delegate: Item {
                id: pill
                required property var modelData

                implicitWidth:  pillBg.implicitWidth
                implicitHeight: Theme.barHeight

                Rectangle {
                    id: pillBg
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth:  modelData.active
                        ? Math.max(nameLabel.implicitWidth + Theme.spacingMd * 2, 28)
                        : 20
                    implicitHeight: 20
                    radius:         Theme.radiusFull

                    color: modelData.active
                        ? Theme.accent
                        : (hov.containsMouse ? Theme.surfaceElevated : Theme.surface)

                    Behavior on color {
                        ColorAnimation { duration: Theme.durationNormal }
                    }
                    Behavior on implicitWidth {
                        NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
                    }

                    // Workspace name / number
                    Text {
                        id: nameLabel
                        anchors.centerIn: parent
                        text:             modelData.name !== "" ? modelData.name : modelData.id
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.sizeCaption
                        font.weight:      Theme.weightSemibold
                        color:            modelData.active ? "#ffffff" : Theme.textSecondary
                        visible:          modelData.active
                    }

                    // Dot for inactive with windows
                    Rectangle {
                        anchors.centerIn: parent
                        width:  6; height: 6
                        radius: 3
                        color:  modelData.windows > 0 ? Theme.textSecondary : Theme.textDisabled
                        visible: !modelData.active
                    }
                }

                HoverHandler { id: hov }

                TapHandler {
                    onTapped: CompositorService.switchWorkspace(modelData.id)
                }
            }
        }
    }
}
