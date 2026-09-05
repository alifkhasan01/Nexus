import QtQuick
import QtQuick.Controls.Basic as Controls
import "../../theme"
import "../../components"

// LauncherSearch — search input bar with icon
Item {
    id: root

    property alias text: input.text

    signal moveDown()
    signal moveUp()
    signal confirm()
    signal dismissed()

    implicitHeight: 52
    implicitWidth:  parent.width

    function clear() { input.text = "" }
    function forceActiveFocus() { input.forceActiveFocus() }

    Row {
        anchors {
            fill:          parent
            leftMargin:    Theme.spacingLg
            rightMargin:   Theme.spacingLg
        }
        spacing: Theme.spacingMd

        // Search icon
        Image {
            anchors.verticalCenter: parent.verticalCenter
            width:  Theme.iconMd
            height: Theme.iconMd
            source: "image://theme/system-search"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.5
        }

        // Text input
        Controls.TextField {
            id: input
            anchors.verticalCenter: parent.verticalCenter
            width:  parent.width - Theme.iconMd - Theme.spacingMd

            placeholderText: "Search apps, run commands…"
            font.family:     Theme.fontFamily
            font.pixelSize:  Theme.sizeTitle
            font.weight:     Theme.weightMedium
            color:           Theme.text
            selectionColor:  Theme.accent

            background: null  // transparent — container provides bg

            Keys.onDownPressed:   root.moveDown()
            Keys.onUpPressed:     root.moveUp()
            Keys.onReturnPressed: root.confirm()
            Keys.onEscapePressed: root.dismissed()

            onTextChanged: {} // textChanged signal is auto-emitted by the alias property
        }

        // Clear button
        NxIconButton {
            anchors.verticalCenter: parent.verticalCenter
            visible:    input.text.length > 0
            iconName:   "image://theme/edit-clear"
            buttonSize: Theme.iconMd + Theme.spacingSm
            iconSize:   Theme.iconSm
            onClicked:  root.clear()
        }
    }
}
