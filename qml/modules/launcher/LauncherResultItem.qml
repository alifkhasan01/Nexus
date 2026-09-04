import QtQuick
import "../../theme"
import "../../components"

// LauncherResultItem — single row in the launcher results list
Item {
    id: root

    property string appName: ""
    property string appIcon: ""
    property string appId:   ""
    property bool   selected: false

    signal clicked()
    signal hovered()

    implicitHeight: 52
    implicitWidth:  parent ? parent.width : 400

    // Selection / hover background
    Rectangle {
        anchors {
            fill:           parent
            leftMargin:     Theme.spacingSm
            rightMargin:    Theme.spacingSm
        }
        radius: Theme.radiusMd
        color:  root.selected
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            : (hov.hovered ? Theme.surfaceHighlight : "transparent")

        Behavior on color {
            ColorAnimation { duration: Theme.durationFast }
        }

        // Left accent bar when selected
        Rectangle {
            anchors {
                left:         parent.left
                leftMargin:   2
                verticalCenter: parent.verticalCenter
            }
            width:  3
            height: 20
            radius: 2
            color:  Theme.accent
            visible: root.selected
            opacity: 0.85
        }
    }

    Row {
        anchors {
            fill:         parent
            leftMargin:   Theme.spacingLg + Theme.spacingSm
            rightMargin:  Theme.spacingLg
        }
        spacing: Theme.spacingMd

        // App icon
        Image {
            anchors.verticalCenter: parent.verticalCenter
            width:  Theme.iconLg
            height: Theme.iconLg
            source: root.appIcon
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            onStatusChanged: {
                if (status === Image.Error)
                    source = "image://theme/application-default-icon"
            }
        }

        // App name
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text:           root.appName
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBody
                font.weight:    root.selected ? Theme.weightSemibold : Theme.weightRegular
                color:          root.selected ? Theme.text : Theme.text
                elide:          Text.ElideRight
            }

            Text {
                text:           root.appId
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                color:          Theme.textDisabled
                elide:          Text.ElideRight
                visible:        root.selected
            }
        }
    }

    HoverHandler {
        id: hov
        onHoveredChanged: if (hov.hovered) root.hovered()
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
