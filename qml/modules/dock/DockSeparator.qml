import QtQuick
import "../../theme"

// DockSeparator — vertical divider between pinned and running apps
Item {
    implicitWidth:  Theme.spacingMd
    implicitHeight: Theme.dockIconSize

    Rectangle {
        anchors.centerIn: parent
        width:   1
        height:  parent.height * 0.5
        radius:  1
        color:   Theme.border
        opacity: 0.6
    }
}
