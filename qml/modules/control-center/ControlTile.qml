import QtQuick
import QtQuick.Layouts
import "../../theme"

// ControlTile — toggleable square tile for quick settings
Item {
    id: root

    property string label:    ""
    property string icon:     ""
    property bool   active:   false
    property string subtitle: ""

    signal toggled()

    implicitWidth:  160
    implicitHeight: 64

    HoverHandler { id: hov }

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color: {
            if (root.active)         return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20)
            if (hov.hovered)         return Theme.surfaceHighlight
            return Theme.surfaceElevated
        }
        border.color: root.active ? Theme.accent : Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        RowLayout {
            anchors {
                fill:        parent
                margins:     Theme.spacingMd
            }
            spacing: Theme.spacingMd

            // Icon
            Rectangle {
                width:  36; height: 36
                radius: Theme.radiusSm
                color:  root.active
                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                    : Theme.surface

                Image {
                    anchors.centerIn: parent
                    width:  Theme.iconMd; height: Theme.iconMd
                    source: "image://theme/" + root.icon
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    onStatusChanged: if (status === Image.Error) source = "image://theme/emblem-default"
                }
            }

            // Labels
            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text:           root.label
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBodySmall
                    font.weight:    Theme.weightSemibold
                    color:          root.active ? Theme.accent : Theme.text
                    elide:          Text.ElideRight
                    width:          parent.width
                }
                Text {
                    text:           root.subtitle
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    elide:          Text.ElideRight
                    width:          parent.width
                }
            }
        }
    }

    TapHandler { onTapped: root.toggled() }
    scale: hov.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.durationFast } }
}
