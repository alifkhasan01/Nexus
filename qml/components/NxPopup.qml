import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxPopup — glass-panel floating overlay
Controls.Popup {
    id: root

    property int   popupRadius:  Theme.radiusLg
    property int   popupPadding: Theme.spacingLg
    property bool  showScrim:    false

    padding: popupPadding
    modal:   showScrim

    // ── Background ──────────────────────────────────────────
    background: Rectangle {
        color:        Theme.surface
        radius:       root.popupRadius
        border.color: Theme.border
        border.width: Theme.borderThin
        opacity:      Theme.glassOpacity

        // Subtle inner top highlight for glass effect
        Rectangle {
            anchors {
                top:   parent.top
                left:  parent.left
                right: parent.right
            }
            height: 1
            color:  Theme.borderSubtle
            radius: root.popupRadius
        }
    }

    // ── Optional scrim ───────────────────────────────────────
    Controls.Overlay.modal: Rectangle {
        color: Theme.scrim
        opacity: 0.4
    }

    // ── Open/close animation ─────────────────────────────────
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0; to: 1.0
                duration: Theme.durationNormal
                easing.type: Theme.easingDecelerate
            }
            NumberAnimation {
                property: "scale"
                from: 0.94; to: 1.0
                duration: Theme.durationNormal
                easing.type: Theme.easingDecelerate
            }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 0.0
                duration: Theme.durationFast
                easing.type: Theme.easingAccelerate
            }
            NumberAnimation {
                property: "scale"
                from: 1.0; to: 0.96
                duration: Theme.durationFast
                easing.type: Theme.easingAccelerate
            }
        }
    }
}
