import QtQuick
import QtQuick.Layouts
import "../"
import "../../../theme"
import "../../../components"

// ─────────────────────────────────────────────────────────────
// AppearancePage — theme, font, accent colour, animations
// ─────────────────────────────────────────────────────────────
SettingsPage {
    pageTitle:    "Appearance"
    pageSubtitle: "Colours, typography, and motion settings."

    // ── Accent colour ─────────────────────────────────────────
    SettingsSection {
        label: "Accent Color"

        SettingsRow {
            rowLabel:    "Color"
            rowSubtitle: "Used for selections, highlights, and active states."

            Row {
                spacing: Theme.spacingSm

                Repeater {
                    model: [
                        "#3b82f6", // blue  (default)
                        "#8b5cf6", // violet
                        "#ec4899", // pink
                        "#ef4444", // red
                        "#f59e0b", // amber
                        "#22c55e", // green
                        "#06b6d4", // cyan
                    ]

                    delegate: Item {
                        required property string modelData
                        width: 28; height: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width:  24; height: 24
                            radius: 12
                            color:  modelData

                            // Selected ring
                            Rectangle {
                                anchors.centerIn: parent
                                width:  parent.width + 4
                                height: parent.height + 4
                                radius: (parent.width + 4) / 2
                                color:  "transparent"
                                border.color: modelData
                                border.width: 2
                                visible: modelData === Theme.accent
                            }

                            TapHandler {
                                onTapped: {
                                    // TODO: persist to config and reload Theme
                                    console.log("Accent selected:", modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Font ──────────────────────────────────────────────────
    SettingsSection {
        label: "Typography"

        SettingsRow {
            rowLabel:    "Interface font"
            rowSubtitle: "Used throughout the shell UI."

            Text {
                text:           Theme.fontFamily
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBody
                color:          Theme.textSecondary
            }
        }

        SettingsRow {
            rowLabel:    "Monospace font"
            rowSubtitle: "Used in clock, timestamps, and code."

            Text {
                text:           Theme.fontFamilyMono
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.sizeBody
                color:          Theme.textSecondary
            }
        }
    }

    // ── Motion ────────────────────────────────────────────────
    SettingsSection {
        label: "Motion"

        SettingsRow {
            rowLabel:    "Reduce motion"
            rowSubtitle: "Disables transitions and animations across the shell."

            NxToggle {
                checked: Theme.reducedMotion
                onToggled: {
                    // TODO: persist to config
                    console.log("Reduce motion:", checked)
                }
            }
        }
    }

    // ── Panel style ───────────────────────────────────────────
    SettingsSection {
        label: "Panels"

        SettingsRow {
            rowLabel:    "Background blur"
            rowSubtitle: "Frosted glass effect on bar, dock, and popups."

            NxToggle {
                checked: true
                onToggled: console.log("Blur:", checked)
            }
        }

        SettingsRow {
            rowLabel:    "Panel opacity"
            rowSubtitle: "Overall translucency of shell surfaces."

            NxSlider {
                width:    160
                from:     0.5
                to:       1.0
                value:    Theme.glassOpacity
                stepSize: 0.05
                onMoved: console.log("Opacity:", value)
            }
        }
    }
}
