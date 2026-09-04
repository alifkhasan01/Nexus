import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// MediaPlayer — standalone floating media controls panel
// (Can also be embedded in ControlCenter via MediaCard.qml)
//
// Shows:
//   - Large artwork
//   - Title + artist + player name
//   - Progress bar with timestamps
//   - Play/pause, prev/next, shuffle, repeat
//   - Player switcher if multiple MPRIS players are active
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var  screen
    property bool          visible: false
    signal close()

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.OnDemand
    WlrLayershell.anchors: WlrAnchors { bottom: true; right: true }

    implicitWidth:  screen.width
    implicitHeight: screen.height
    color: "transparent"

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationNormal }
    }

    // Scrim
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: 0.35
        TapHandler { onTapped: root.close() }
    }

    // ── Current player ────────────────────────────────────────
    property var player: MprisController.currentPlayer

    // ── Panel ─────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            bottom:      parent.bottom
            right:       parent.right
            bottomMargin: 80   // above dock
            rightMargin:  Theme.spacingMd
        }
        width:   360
        height:  contentCol.implicitHeight + Theme.spacingLg * 2
        radius:  Theme.radiusXl
        color:   Theme.surface
        opacity: Theme.glassOpacity + 0.05
        border.color: Theme.border
        border.width: 1
        clip: true

        scale: root.visible ? 1.0 : 0.95
        Behavior on scale {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
        }

        Column {
            id: contentCol
            anchors {
                top:   parent.top
                left:  parent.left
                right: parent.right
                topMargin:   Theme.spacingLg
                leftMargin:  Theme.spacingLg
                rightMargin: Theme.spacingLg
            }
            spacing: Theme.spacingLg

            // ── Artwork ──────────────────────────────────────
            MediaArtwork {
                anchors.horizontalCenter: parent.horizontalCenter
                size:    280
                artUrl:  root.player ? root.player.trackArtUrl : ""
            }

            // ── Track info ───────────────────────────────────
            Column {
                width:   parent.width
                spacing: Theme.spacingXs

                Text {
                    width:          parent.width
                    text:           root.player ? root.player.trackTitle : "Nothing playing"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeTitle
                    font.weight:    Theme.weightSemibold
                    color:          Theme.text
                    elide:          Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width:          parent.width
                    text:           root.player ? root.player.trackArtist : ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBody
                    color:          Theme.textSecondary
                    elide:          Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    visible:        text !== ""
                }

                Text {
                    width:          parent.width
                    text:           root.player ? root.player.identity : ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textDisabled
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                }
            }

            // ── Progress ──────────────────────────────────────
            MediaProgress {
                width:   parent.width
                player:  root.player
            }

            // ── Controls ──────────────────────────────────────
            MediaControls {
                anchors.horizontalCenter: parent.horizontalCenter
                player: root.player
            }

            // ── Player switcher ──────────────────────────────
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingXs
                visible: MprisController.players.length > 1

                Repeater {
                    model: MprisController.players

                    delegate: Item {
                        required property var modelData

                        width:  8; height: 8

                        Rectangle {
                            anchors.centerIn: parent
                            width:  parent.width
                            height: parent.height
                            radius: 4
                            color: modelData === root.player ? Theme.accent : Theme.border

                            TapHandler {
                                onTapped: MprisController.currentPlayer = modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
