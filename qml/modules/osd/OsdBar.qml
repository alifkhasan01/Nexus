import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// OsdBar — the visual pill: icon + progress bar + value label
Item {
    id: root

    property string osdType:  "volume"
    property real   osdValue: 0.0
    property bool   osdMuted: false

    implicitWidth:  Theme.osdWidth
    implicitHeight: Theme.osdHeight

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusFull
        color:        Theme.surfaceElevated
        opacity:      0.92
        border.color: Theme.border
        border.width: 1

        RowLayout {
            anchors {
                fill:           parent
                leftMargin:     Theme.spacingMd
                rightMargin:    Theme.spacingMd
            }
            spacing: Theme.spacingMd

            // Icon
            Image {
                width:  Theme.iconMd; height: Theme.iconMd
                source: iconForType()
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // Progress bar
            NxProgressBar {
                Layout.fillWidth: true
                height:   6
                value:    Math.min(root.osdValue, 1.0)   // cap at 1.0 for bar
                fillColor: {
                    if (root.osdMuted)           return Theme.border
                    if (root.osdType === "brightness") return "#f59e0b"
                    if (root.osdType === "mic")   return Theme.info
                    return Theme.accent
                }
            }

            // Value label
            Text {
                text:           Math.round(root.osdValue * 100) + "%"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                font.weight:    Theme.weightSemibold
                color:          root.osdMuted ? Theme.textDisabled : Theme.textSecondary
                horizontalAlignment: Text.AlignRight
                width: 34
            }
        }
    }

    function iconForType() {
        switch (root.osdType) {
        case "volume":
            if (root.osdMuted || root.osdValue === 0)
                return "image://theme/audio-volume-muted"
            if (root.osdValue < 0.33)
                return "image://theme/audio-volume-low"
            if (root.osdValue < 0.66)
                return "image://theme/audio-volume-medium"
            return "image://theme/audio-volume-high"

        case "brightness":
            return "image://theme/display-brightness"

        case "mic":
            return root.osdMuted
                ? "image://theme/microphone-sensitivity-muted"
                : "image://theme/microphone-sensitivity-high"

        default:
            return "image://theme/dialog-information"
        }
    }
}
