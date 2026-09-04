import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// AudioControls — volume + mic sliders
Column {
    spacing: Theme.spacingMd

    // ── Output volume ────────────────────────────────────────
    Row {
        width:   parent.width
        spacing: Theme.spacingSm

        // Mute toggle icon
        NxIconButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: AudioService.muted
                ? "image://theme/audio-volume-muted"
                : (AudioService.volume < 33
                    ? "image://theme/audio-volume-low"
                    : AudioService.volume < 66
                        ? "image://theme/audio-volume-medium"
                        : "image://theme/audio-volume-high")
            iconSize:   Theme.iconMd
            buttonSize: Theme.iconMd + Theme.spacingSm
            onClicked:  AudioService.toggleMute()
            NxTooltip { text: AudioService.muted ? "Unmute" : "Mute" }
        }

        NxSlider {
            anchors.verticalCenter: parent.verticalCenter
            width:       parent.width - Theme.iconMd - Theme.spacingSm - 44
            from:        0;  to: 150
            value:       AudioService.volume
            fillColor:   AudioService.muted ? Theme.border : Theme.accent
            onMoved:     AudioService.volume = Math.round(value)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width:          40
            text:           AudioService.volume + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightMedium
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
        }
    }

    // ── Microphone ───────────────────────────────────────────
    Row {
        width:   parent.width
        spacing: Theme.spacingSm

        NxIconButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: AudioService.micMuted
                ? "image://theme/microphone-sensitivity-muted"
                : "image://theme/microphone-sensitivity-high"
            iconSize:   Theme.iconMd
            buttonSize: Theme.iconMd + Theme.spacingSm
            onClicked:  AudioService.toggleMicMute()
            NxTooltip { text: AudioService.micMuted ? "Unmute mic" : "Mute mic" }
        }

        NxSlider {
            anchors.verticalCenter: parent.verticalCenter
            width:       parent.width - Theme.iconMd - Theme.spacingSm - 44
            from:        0;  to: 100
            value:       AudioService.micVolume
            fillColor:   AudioService.micMuted ? Theme.border : Theme.info
            onMoved:     AudioService.micVolume = Math.round(value)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width:          40
            text:           AudioService.micVolume + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightMedium
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
        }
    }
}
