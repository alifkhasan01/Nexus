import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../theme"
import "../../components"

// SysTray — freedesktop StatusNotifierItem tray icons
Item {
    id: root

    implicitHeight: Theme.barHeight
    implicitWidth:  trayRow.implicitWidth

    RowLayout {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXxs

        Repeater {
            model: SystemTrayModel {}

            delegate: Item {
                id: trayItem
                required property var modelData

                implicitWidth:  Theme.iconSm + Theme.spacingXs * 2
                implicitHeight: Theme.barHeight

                Image {
                    anchors.centerIn: parent
                    width:    Theme.iconSm
                    height:   Theme.iconSm
                    source:   trayItem.modelData.icon
                    fillMode: Image.PreserveAspectFit
                    smooth:   true
                }

                HoverHandler { id: itemHov }

                Rectangle {
                    anchors.fill:  parent
                    radius:        Theme.radiusSm
                    color:         itemHov.hovered ? Theme.surfaceHighlight : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                // Left click: activate
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: trayItem.modelData.activate(
                        trayItem.x + trayItem.width / 2,
                        trayItem.y + trayItem.height
                    )
                }

                // Right click: context menu
                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: contextMenu.visible = true
                }

                // Minimal context menu placeholder
                // Full DBusMenu integration provided by Quickshell.DBusMenu
                Rectangle {
                    id: contextMenu
                    visible: false
                    z: 100
                    y: parent.height
                    width: 160
                    height: 40
                    radius: Theme.radiusSm
                    color: Theme.surfaceElevated
                    border.color: Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "Menu coming soon"
                        font.pixelSize: Theme.sizeCaption
                        color: Theme.textSecondary
                    }

                    TapHandler { onTapped: contextMenu.visible = false }
                }

                NxTooltip { text: trayItem.modelData.tooltip || trayItem.modelData.title }
            }
        }
    }
}
