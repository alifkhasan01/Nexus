import QtQuick
import "../../theme"
import "../../components"

// WindowThumb — window card in the overview grid
Item {
    id: root

    property int    thumbWidth:   260
    property int    thumbHeight:  146
    property string windowTitle:  ""
    property string windowClass:  ""
    property bool   isFocused:    false
    property bool   isFloating:   false

    signal clicked()
    signal closeRequested()

    implicitWidth:  thumbWidth
    implicitHeight: thumbHeight + 28  // + title bar

    HoverHandler { id: hov }

    // Card background
    Rectangle {
        id: card
        width:  root.thumbWidth
        height: root.thumbHeight
        radius: Theme.radiusMd
        color:  Theme.surfaceElevated

        border.color: root.isFocused ? Theme.accent : Theme.border
        border.width: root.isFocused ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        // Window content placeholder (actual screencopy requires WlrScreencopy)
        Item {
            anchors.fill:    parent
            anchors.margins: 1
            clip:            true

            // App icon centered as preview fallback
            Image {
                anchors.centerIn: parent
                width:   Theme.iconHuge
                height:  Theme.iconHuge
                source:  "image://theme/" + root.windowClass.toLowerCase()
                fillMode: Image.PreserveAspectFit
                smooth:  true
                opacity: 0.35

                onStatusChanged: {
                    if (status === Image.Error)
                        source = "image://theme/application-default-icon"
                }
            }

            // Floating badge
            Rectangle {
                anchors { top: parent.top; right: parent.right; margins: Theme.spacingXs }
                width:  40; height: 16
                radius: Theme.radiusFull
                color:  Theme.surfaceHighlight
                visible: root.isFloating

                Text {
                    anchors.centerIn: parent
                    text:           "float"
                    font.pixelSize: Theme.sizeCaption - 1
                    color:          Theme.textSecondary
                }
            }
        }

        // Close button — shown on hover
        Rectangle {
            anchors { top: parent.top; right: parent.right; margins: -6 }
            width:  22; height: 22
            radius: 11
            color:  closeHov.hovered ? Theme.error : Theme.surfaceHighlight
            visible: hov.hovered
            z: 10

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            Text {
                anchors.centerIn: parent
                text:           "✕"
                font.pixelSize: Theme.sizeCaption
                color:          "#ffffff"
            }

            HoverHandler { id: closeHov }
            TapHandler {
                onTapped: root.closeRequested()
            }
        }

        // Scale on hover
        scale: hov.hovered ? 1.03 : 1.0
        Behavior on scale {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
        }
    }

    // Title bar below card
    Row {
        anchors {
            top:              card.bottom
            topMargin:        Theme.spacingXs
            horizontalCenter: card.horizontalCenter
        }
        spacing: Theme.spacingXs

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width:  Theme.iconSm; height: Theme.iconSm
            source: "image://theme/" + root.windowClass.toLowerCase()
            fillMode: Image.PreserveAspectFit
            smooth: true
            onStatusChanged: if (status === Image.Error) source = "image://theme/application-default-icon"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:           root.windowTitle !== "" ? root.windowTitle : root.windowClass
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    root.isFocused ? Theme.weightSemibold : Theme.weightRegular
            color:          root.isFocused ? Theme.text : Theme.textSecondary
            elide:          Text.ElideRight
            maximumLineCount: 1
            width:          root.thumbWidth - Theme.iconSm - Theme.spacingXs
        }
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
