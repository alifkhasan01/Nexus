import QtQuick
import "../theme"

// NxSeparator — horizontal or vertical divider
Item {
    id: root

    property bool   vertical:  false
    property color  lineColor: Theme.border
    property int    thickness: 1

    implicitWidth:  vertical ? thickness : 1
    implicitHeight: vertical ? 1 : thickness

    Rectangle {
        anchors.centerIn: parent
        width:  root.vertical ? root.thickness : root.width
        height: root.vertical ? root.height    : root.thickness
        color:  root.lineColor
        opacity: 0.7
    }
}
