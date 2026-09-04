import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxScrollView — scroll area with styled scrollbar
Controls.ScrollView {
    id: root

    property int scrollBarWidth: 4

    ScrollBar.vertical: Controls.ScrollBar {
        id: vbar
        width: root.scrollBarWidth + 4
        policy: Controls.ScrollBar.AsNeeded

        contentItem: Rectangle {
            implicitWidth:  root.scrollBarWidth
            implicitHeight: 80
            radius: root.scrollBarWidth / 2
            color:  vbar.pressed ? Theme.textSecondary : Theme.border
            opacity: vbar.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: Theme.durationNormal }
            }
        }

        background: Rectangle { color: "transparent" }
    }

    ScrollBar.horizontal: Controls.ScrollBar {
        policy: Controls.ScrollBar.AlwaysOff
    }
}
