import QtQuick
import QtQuick.Layouts
import "../"
import "../../../theme"
import "../../../components"

// ─────────────────────────────────────────────────────────────
// NotificationsPage — banner style, DND, per-app settings
// ─────────────────────────────────────────────────────────────
SettingsPage {
    pageTitle:    "Notifications"
    pageSubtitle: "Control how and when notifications are shown."

    // ── Global ────────────────────────────────────────────────
    SettingsSection {
        label: "Global"

        SettingsRow {
            rowLabel:    "Do Not Disturb"
            rowSubtitle: "Silence all notification banners. Notifications still go to center."
            NxToggle { checked: false; onToggled: console.log("DND:", checked) }
        }

        SettingsRow {
            rowLabel:    "Show banners"
            rowSubtitle: "Display pop-up banners in the top-right corner."
            NxToggle { checked: true; onToggled: console.log("Banners:", checked) }
        }
    }

    // ── Banner ────────────────────────────────────────────────
    SettingsSection {
        label: "Banner"

        SettingsRow {
            rowLabel:    "Banner timeout"
            rowSubtitle: "How long a banner stays on screen before auto-dismissing."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: timeoutSlider
                    width:    140
                    from:     2
                    to:       15
                    value:    5
                    stepSize: 1
                }

                Text {
                    text:           timeoutSlider.value + " s"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          32
                }
            }
        }

        SettingsRow {
            rowLabel:    "Banner position"
            rowSubtitle: "Corner of the screen where banners appear."

            Row {
                spacing: Theme.spacingXs

                Repeater {
                    model: ["Top Right", "Top Left", "Bottom Right"]
                    NxButton {
                        required property string modelData
                        text:    modelData
                        variant: modelData === "Top Right"
                            ? NxButton.Variant.Primary
                            : NxButton.Variant.Secondary
                        implicitHeight: 28
                        onClicked: console.log("Banner pos:", modelData)
                    }
                }
            }
        }

        SettingsRow {
            rowLabel:    "Show notification body in banner"
            rowSubtitle: "Expand the preview to show full body text."
            NxToggle { checked: true; onToggled: console.log("Show body:", checked) }
        }
    }

    // ── Notification center ───────────────────────────────────
    SettingsSection {
        label: "Notification Center"

        SettingsRow {
            rowLabel:    "Group by app"
            rowSubtitle: "Collapse notifications from the same application."
            NxToggle { checked: true; onToggled: console.log("Group by app:", checked) }
        }

        SettingsRow {
            rowLabel:    "Max notifications shown"
            rowSubtitle: "Older notifications are removed when this limit is reached."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: maxSlider
                    width:    140
                    from:     10
                    to:       100
                    value:    50
                    stepSize: 10
                }

                Text {
                    text:           maxSlider.value.toString()
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          32
                }
            }
        }
    }

    // ── Sound ─────────────────────────────────────────────────
    SettingsSection {
        label: "Sound"

        SettingsRow {
            rowLabel:    "Notification sound"
            rowSubtitle: "Play a sound when a notification arrives."
            NxToggle { checked: false; onToggled: console.log("Notif sound:", checked) }
        }
    }
}
