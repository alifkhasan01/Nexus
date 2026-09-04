import QtQuick
import QtQuick.Layouts
import "../"
import "../../../theme"
import "../../../components"

// ─────────────────────────────────────────────────────────────
// BarPage — top bar visibility, height, and module toggles
// ─────────────────────────────────────────────────────────────
SettingsPage {
    pageTitle:    "Bar"
    pageSubtitle: "Configure the top status bar."

    // ── General ───────────────────────────────────────────────
    SettingsSection {
        label: "General"

        SettingsRow {
            rowLabel:    "Show bar"
            rowSubtitle: "Hide to use the screen edge without a bar."

            NxToggle {
                checked: true
                onToggled: console.log("Bar visible:", checked)
            }
        }

        SettingsRow {
            rowLabel:    "Bar height"
            rowSubtitle: "Height in pixels. Default: 32 px."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    width:    140
                    from:     24
                    to:       48
                    value:    Theme.barHeight
                    stepSize: 2
                    onMoved:  console.log("Bar height:", Math.round(value))
                }

                Text {
                    text:           Math.round(parent.children[0].value) + " px"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          36
                }
            }
        }
    }

    // ── Left section ──────────────────────────────────────────
    SettingsSection {
        label: "Left Section"

        SettingsRow {
            rowLabel: "Workspace indicator"
            NxToggle { checked: true; onToggled: console.log("WS indicator:", checked) }
        }

        SettingsRow {
            rowLabel: "Active app label"
            NxToggle { checked: true; onToggled: console.log("App label:", checked) }
        }
    }

    // ── Center section ────────────────────────────────────────
    SettingsSection {
        label: "Center Section"

        SettingsRow {
            rowLabel: "Clock"
            NxToggle { checked: true; onToggled: console.log("Clock:", checked) }
        }

        SettingsRow {
            rowLabel:    "Clock format"
            rowSubtitle: "24-hour or 12-hour time display."

            Row {
                spacing: Theme.spacingXs

                NxButton {
                    text:    "24h"
                    variant: NxButton.Variant.Primary
                    implicitHeight: 28
                    onClicked: console.log("Clock format: 24h")
                }
                NxButton {
                    text:    "12h"
                    variant: NxButton.Variant.Secondary
                    implicitHeight: 28
                    onClicked: console.log("Clock format: 12h")
                }
            }
        }
    }

    // ── Right section ─────────────────────────────────────────
    SettingsSection {
        label: "Right Section"

        SettingsRow {
            rowLabel: "System tray"
            NxToggle { checked: true; onToggled: console.log("Tray:", checked) }
        }

        SettingsRow {
            rowLabel: "Network icon"
            NxToggle { checked: true; onToggled: console.log("Network icon:", checked) }
        }

        SettingsRow {
            rowLabel: "Volume icon"
            NxToggle { checked: true; onToggled: console.log("Volume icon:", checked) }
        }

        SettingsRow {
            rowLabel: "Battery icon"
            NxToggle { checked: true; onToggled: console.log("Battery icon:", checked) }
        }

        SettingsRow {
            rowLabel: "Notification button"
            NxToggle { checked: true; onToggled: console.log("Notif button:", checked) }
        }
    }
}
