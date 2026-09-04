import QtQuick
import "../../theme"
import "../../components"

// BarButton — small icon button used inside the bar
NxIconButton {
    property bool active: false

    buttonSize: Theme.barHeight - 4
    iconSize:   Theme.iconSm

    // Active indicator — subtle accent underline
    Rectangle {
        anchors {
            bottom:           parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin:     1
        }
        width:   12
        height:  2
        radius:  1
        color:   Theme.accent
        visible: parent.active
        opacity: 0.8
    }
}
