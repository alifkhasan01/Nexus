import QtQuick
import Nexus.Services 1.0
import "../../theme"

// ActiveAppLabel — shows focused window app name + title
Item {
    id: root

    implicitHeight: Theme.barHeight
    implicitWidth:  Math.min(row.implicitWidth, 260)
    clip: true

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSm

        // App icon (via theme icon)
        Image {
            anchors.verticalCenter: parent.verticalCenter
            width:  Theme.iconSm
            height: Theme.iconSm
            source: appClass !== "" ? "image://theme/" + appClass.toLowerCase() : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: status === Image.Ready
        }

        // App class name
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:            appClass
            font.family:     Theme.fontFamily
            font.pixelSize:  Theme.sizeBodySmall
            font.weight:     Theme.weightSemibold
            color:           Theme.text
            visible:         appClass !== ""
            elide:           Text.ElideRight
            maximumLineCount: 1
        }

        // Separator dot when both class and title available
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:   "—"
            font.pixelSize: Theme.sizeCaption
            color:  Theme.textDisabled
            visible: appClass !== "" && appTitle !== ""
        }

        // Window title
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:           appTitle
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeBodySmall
            color:          Theme.textSecondary
            elide:          Text.ElideRight
            maximumLineCount: 1
            width:          Math.max(0, root.width - (appClass !== "" ? 140 : 0))
            visible:        appTitle !== "" && appClass !== appTitle
        }
    }

    // ── Data bindings ────────────────────────────────────────
    readonly property string appClass: CompositorService.activeAppClass
    readonly property string appTitle: CompositorService.activeAppTitle

    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }
}
