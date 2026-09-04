import QtQuick
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// WallpaperThumb — single wallpaper thumbnail card
//
// Shows a preview image with selection ring and hover overlay.
// Emits clicked() so WallpaperPicker can set it as active.
// ─────────────────────────────────────────────────────────────
Item {
    id: root

    property string filePath:  ""   // absolute path to image file
    property string fileName:  ""   // display name (basename, no ext)
    property bool   selected:  false

    signal clicked()

    implicitWidth:  160
    implicitHeight: 110

    HoverHandler { id: hov }

    // ── Card ─────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.surfaceHighlight
        clip:         true

        border.color: root.selected ? Theme.accent : (hov.hovered ? Theme.borderFocus : Theme.border)
        border.width: root.selected ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        // Wallpaper preview
        Image {
            id: preview
            anchors.fill:    parent
            anchors.margins: root.selected ? 3 : 2
            source:          root.filePath !== "" ? ("file://" + root.filePath) : ""
            fillMode:        Image.PreserveAspectCrop
            smooth:          true
            mipmap:          true
            asynchronous:    true
            cache:           true

            Behavior on anchors.margins {
                NumberAnimation { duration: Theme.durationFast }
            }

            // Loading placeholder
            Rectangle {
                anchors.fill: parent
                color:        Theme.surface
                visible:      preview.status !== Image.Ready

                Image {
                    anchors.centerIn: parent
                    width:   Theme.iconLg; height: Theme.iconLg
                    source:  "image://theme/image-missing"
                    opacity: 0.3
                }
            }
        }

        // Hover overlay with filename
        Rectangle {
            anchors {
                left:   parent.left
                right:  parent.right
                bottom: parent.bottom
            }
            height:  28
            radius:  parent.radius
            // Only round bottom corners visually via gradient overlay
            color:   "#bb000000"
            visible: hov.hovered || root.selected

            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

            Text {
                anchors {
                    left:           parent.left
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin:     Theme.spacingSm
                    rightMargin:    Theme.spacingSm
                }
                text:           root.fileName
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                font.weight:    Theme.weightMedium
                color:          "#ffffff"
                elide:          Text.ElideRight
            }
        }

        // Selected checkmark badge
        Rectangle {
            anchors {
                top:   parent.top
                right: parent.right
                margins: Theme.spacingXs
            }
            width:  20; height: 20
            radius: 10
            color:  Theme.accent
            visible: root.selected
            z: 1

            Text {
                anchors.centerIn: parent
                text:           "✓"
                font.pixelSize: Theme.sizeCaption
                color:          "#ffffff"
                font.weight:    Theme.weightBold
            }
        }
    }

    // Scale feedback on hover
    scale: hov.hovered ? 1.03 : 1.0
    Behavior on scale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
    }

    TapHandler { onTapped: root.clicked() }

    NxTooltip { text: root.fileName }
}
