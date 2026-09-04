import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// MediaProgress — MPRIS progress bar with timestamps and seek
//
// Shows:
//   - Current position (left)
//   - Scrubable progress bar (center)
//   - Total duration (right)
//
// Ticks every second via Timer; dragging the bar seeks via
// player.setPosition(). Cleans up gracefully when no player.
// ─────────────────────────────────────────────────────────────
Item {
    id: root

    property var player: null

    implicitWidth:  300
    implicitHeight: 32

    // ── Internal state ────────────────────────────────────────
    // Track whether the user is currently dragging so we don't
    // fight the timer updates while scrubbing.
    property bool scrubbing:    false
    property real scrubValue:   0.0   // 0.0–1.0 during drag
    property real displayValue: {
        if (scrubbing) return scrubValue
        if (!root.player || root.player.length <= 0) return 0
        return Math.min(root.player.position / root.player.length, 1.0)
    }

    // ── Progress tick ─────────────────────────────────────────
    Timer {
        id: progressTimer
        interval: 1000
        repeat:   true
        running:  root.player !== null
                  && root.player.playbackStatus === "Playing"
                  && !root.scrubbing
        onTriggered: {
            // Force re-evaluation of displayValue binding
            root.player.positionChanged()
        }
    }

    // ── Layout ────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingSm

        // Current position
        Text {
            id: posLabel
            text:           formatTime(root.player ? root.player.position : 0)
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightMedium
            color:          Theme.textSecondary
            minimumPixelSize: Theme.sizeCaption
            width: 36
            horizontalAlignment: Text.AlignRight
        }

        // ── Scrub bar ─────────────────────────────────────────
        Item {
            id: trackArea
            Layout.fillWidth: true
            height: 20   // hit area

            // Track background
            Rectangle {
                id: trackBg
                anchors.verticalCenter: parent.verticalCenter
                width:  parent.width
                height: 4
                radius: 2
                color:  Theme.border

                // Filled portion
                Rectangle {
                    id: trackFill
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    width:  Math.max(radius, parent.width * root.displayValue)
                    height: parent.height
                    radius: parent.radius
                    color:  Theme.accent

                    Behavior on width {
                        enabled: !root.scrubbing && !Theme.reducedMotion
                        NumberAnimation { duration: 800; easing.type: Easing.Linear }
                    }
                }

                // Scrub handle — only visible on hover or while dragging
                Rectangle {
                    id: handle
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(
                        parent.width * root.displayValue - width / 2,
                        parent.width - width
                    ))
                    width:   12
                    height:  12
                    radius:  6
                    color:   "#ffffff"
                    visible: trackHov.hovered || root.scrubbing
                    z:       1

                    Behavior on x {
                        enabled: !root.scrubbing && !Theme.reducedMotion
                        NumberAnimation { duration: 800; easing.type: Easing.Linear }
                    }

                    layer.enabled: true
                }
            }

            HoverHandler { id: trackHov }

            // Drag to seek
            DragHandler {
                id: dragHandler
                target: null
                dragThreshold: 0
                xAxis.enabled: true
                yAxis.enabled: false

                onActiveChanged: {
                    if (active) {
                        root.scrubbing = true
                    } else {
                        // Commit seek
                        if (root.player && root.player.canSeek && root.player.length > 0) {
                            root.player.position = Math.round(root.scrubValue * root.player.length)
                        }
                        root.scrubbing = false
                    }
                }

                onCentroidChanged: {
                    if (active && trackArea.width > 0) {
                        root.scrubValue = Math.max(0.0,
                            Math.min(1.0, centroid.position.x / trackArea.width))
                    }
                }
            }

            // Tap to seek (click anywhere on track)
            TapHandler {
                onTapped: function(eventPoint) {
                    if (root.player && root.player.canSeek && root.player.length > 0) {
                        var ratio = eventPoint.position.x / trackArea.width
                        root.player.position = Math.round(
                            Math.max(0, Math.min(1, ratio)) * root.player.length
                        )
                    }
                }
            }
        }

        // Total duration
        Text {
            id: durLabel
            text:           formatTime(root.player ? root.player.length : 0)
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightMedium
            color:          Theme.textSecondary
            width: 36
            horizontalAlignment: Text.AlignLeft
        }
    }

    // ── Helpers ───────────────────────────────────────────────
    // Formats microseconds (MPRIS uses µs) to "m:ss"
    function formatTime(us) {
        if (!us || us <= 0) return "0:00"
        var totalSec = Math.floor(us / 1000000)
        var m  = Math.floor(totalSec / 60)
        var s  = totalSec % 60
        return m + ":" + (s < 10 ? "0" + s : s)
    }
}
