import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

// MediaCard — embedded mini media player in Control Center
// Uses the first available MPRIS player
Item {
    id: root

    property var player: MprisController.currentPlayer

    implicitHeight: player ? 72 : 0
    visible:        player !== null && player !== undefined

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1
        clip:         true

        RowLayout {
            anchors {
                fill:    parent
                margins: Theme.spacingMd
            }
            spacing: Theme.spacingMd

            // Artwork
            Rectangle {
                width:   52; height: 52
                radius:  Theme.radiusSm
                color:   Theme.surfaceHighlight

                Image {
                    anchors.fill:   parent
                    anchors.margins: 0
                    source:         root.player ? root.player.trackArtUrl : ""
                    fillMode:       Image.PreserveAspectCrop
                    smooth:         true
                    visible:        source !== ""
                }

                // Fallback icon
                Image {
                    anchors.centerIn: parent
                    width:    Theme.iconMd; height: Theme.iconMd
                    source:   "image://theme/audio-x-generic"
                    visible:  !root.player || root.player.trackArtUrl === ""
                    opacity:  0.4
                }
            }

            // Track info
            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text:           root.player ? root.player.trackTitle : ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBodySmall
                    font.weight:    Theme.weightSemibold
                    color:          Theme.text
                    elide:          Text.ElideRight
                    width:          parent.width
                }
                Text {
                    text:           root.player ? root.player.trackArtist : ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    elide:          Text.ElideRight
                    width:          parent.width
                }
            }

            // Controls
            Row {
                spacing: Theme.spacingXs

                NxIconButton {
                    iconName:   "image://theme/media-skip-backward"
                    iconSize:   Theme.iconSm
                    buttonSize: 28
                    enabled:    root.player ? root.player.canGoPrevious : false
                    onClicked:  root.player.previous()
                }
                NxIconButton {
                    iconName: root.player && root.player.playbackStatus === "Playing"
                        ? "image://theme/media-playback-pause"
                        : "image://theme/media-playback-start"
                    iconSize:   Theme.iconMd
                    buttonSize: 32
                    enabled:    root.player ? root.player.canPlay || root.player.canPause : false
                    onClicked:  root.player.playPause()
                }
                NxIconButton {
                    iconName:   "image://theme/media-skip-forward"
                    iconSize:   Theme.iconSm
                    buttonSize: 28
                    enabled:    root.player ? root.player.canGoNext : false
                    onClicked:  root.player.next()
                }
            }
        }
    }
}
