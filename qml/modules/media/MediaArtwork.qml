import QtQuick
import "../../theme"

// MediaArtwork — album art with rounded corners and fallback
Item {
    id: root

    property string artUrl: ""
    property int    size:   240

    implicitWidth:  size
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusLg
        color:        Theme.surfaceHighlight
        clip:         true

        Image {
            anchors.fill: parent
            source:       root.artUrl
            fillMode:     Image.PreserveAspectCrop
            smooth:       true
            mipmap:       true
            visible:      status === Image.Ready && root.artUrl !== ""

            Behavior on source {
                enabled: !Theme.reducedMotion
                // Crossfade via opacity
                SequentialAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: Theme.durationFast }
                    PropertyAction  { property: "source" }
                    NumberAnimation { property: "opacity"; to: 1; duration: Theme.durationFast }
                }
            }
        }

        // Fallback
        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingMd
            visible: root.artUrl === "" || artImage.status !== Image.Ready

            Image {
                id: artImage
                anchors.horizontalCenter: parent.horizontalCenter
                width:    Theme.iconHuge; height: Theme.iconHuge
                source:   "image://theme/audio-x-generic"
                opacity:  0.3
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    // Subtle shadow
    layer.enabled: true
}
