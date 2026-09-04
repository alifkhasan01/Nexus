import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxTooltip — small informational label attached to a parent
Controls.ToolTip {
    id: root

    delay:   500
    timeout: 3000

    // ── Background ──────────────────────────────────────────
    background: Rectangle {
        color:        Theme.surfaceElevated
        radius:       Theme.radiusXs
        border.color: Theme.border
        border.width: Theme.borderThin
    }

    // ── Content ─────────────────────────────────────────────
    contentItem: Text {
        text:            root.text
        font.family:     Theme.fontFamily
        font.pixelSize:  Theme.sizeCaption
        font.weight:     Theme.weightMedium
        color:           Theme.textSecondary
        leftPadding:     Theme.spacingSm
        rightPadding:    Theme.spacingSm
        topPadding:      Theme.spacingXs
        bottomPadding:   Theme.spacingXs
    }

    // ── Fade transition ──────────────────────────────────────
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0; to: 1.0
            duration: Theme.durationFast
            easing.type: Theme.easingStandard
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0; to: 0.0
            duration: Theme.durationFast
            easing.type: Theme.easingStandard
        }
    }
}
