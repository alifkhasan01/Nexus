import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// MediaControls — playback buttons row
Item {
    id: root

    property var player: null

    implicitWidth:  ctrlRow.implicitWidth
    implicitHeight: 48

    Row {
        id: ctrlRow
        anchors.centerIn: parent
        spacing: Theme.spacingLg

        // Shuffle
        NxIconButton {
            iconName:   "image://theme/media-playlist-shuffle"
            iconSize:   Theme.iconMd
            buttonSize: 40
            subtle:     !root.player || root.player.shuffle === false
            onClicked: {
                if (root.player) root.player.shuffle = !root.player.shuffle
            }
            visible:    root.player && root.player.canControl
        }

        // Previous
        NxIconButton {
            iconName:   "image://theme/media-skip-backward"
            iconSize:   Theme.iconLg
            buttonSize: 44
            enabled:    root.player && root.player.canGoPrevious
            onClicked:  root.player.previous()
            visible:    root.player && root.player.canControl
        }

        // Play/Pause
        NxIconButton {
            iconName: root.player && root.player.playbackStatus === "Playing"
                ? "image://theme/media-playback-pause"
                : "image://theme/media-playback-start"
            iconSize:   Theme.iconXl
            buttonSize: 52
            enabled:    root.player && (root.player.canPlay || root.player.canPause)
            onClicked:  root.player.playPause()
            visible:    root.player && root.player.canControl
        }

        // Next
        NxIconButton {
            iconName:   "image://theme/media-skip-forward"
            iconSize:   Theme.iconLg
            buttonSize: 44
            enabled:    root.player && root.player.canGoNext
            onClicked:  root.player.next()
            visible:    root.player && root.player.canControl
        }

        // Repeat
        NxIconButton {
            property var repeatModes: ["None", "All", "One"]
            property int repeatIdx:   repeatModes.indexOf(root.player ? root.player.loopStatus : "None")

            iconName:   repeatIdx === 2
                ? "image://theme/media-repeat-one"
                : "image://theme/media-repeat"
            iconSize:   Theme.iconMd
            buttonSize: 40
            subtle:     repeatIdx === 0
            onClicked: {
                if (root.player) {
                    root.player.loopStatus = repeatModes[(repeatIdx + 1) % repeatModes.length]
                }
            }
            visible:    root.player && root.player.canControl
        }
    }
}
