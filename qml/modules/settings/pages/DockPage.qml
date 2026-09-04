import QtQuick
import QtQuick.Layouts
import "../"
import "../../../theme"
import "../../../components"

// ─────────────────────────────────────────────────────────────
// DockPage — dock visibility, icon size, auto-hide, position
// ─────────────────────────────────────────────────────────────
SettingsPage {
    pageTitle:    "Dock"
    pageSubtitle: "Configure the application dock."

    // ── General ───────────────────────────────────────────────
    SettingsSection {
        label: "General"

        SettingsRow {
            rowLabel: "Show dock"
            NxToggle { checked: true; onToggled: console.log("Dock visible:", checked) }
        }

        SettingsRow {
            rowLabel:    "Auto-hide"
            rowSubtitle: "Slide the dock out of view when a window overlaps it."
            NxToggle { checked: true; onToggled: console.log("Auto-hide:", checked) }
        }

        SettingsRow {
            rowLabel:    "Position"
            rowSubtitle: "Edge of the screen where the dock is placed."

            Row {
                spacing: Theme.spacingXs

                Repeater {
                    model: ["Bottom", "Left", "Right"]
                    NxButton {
                        required property string modelData
                        text:    modelData
                        variant: modelData === "Bottom"
                            ? NxButton.Variant.Primary
                            : NxButton.Variant.Secondary
                        implicitHeight: 28
                        onClicked: console.log("Dock position:", modelData)
                    }
                }
            }
        }
    }

    // ── Size ──────────────────────────────────────────────────
    SettingsSection {
        label: "Size"

        SettingsRow {
            rowLabel:    "Icon size"
            rowSubtitle: "Base size of dock icons in pixels."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: iconSizeSlider
                    width:    140
                    from:     32
                    to:       72
                    value:    Theme.dockIconSize
                    stepSize: 4
                }

                Text {
                    text:           Math.round(iconSizeSlider.value) + " px"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          36
                }
            }
        }

        SettingsRow {
            rowLabel:    "Magnification"
            rowSubtitle: "Hover zoom effect on dock icons."
            NxToggle { checked: true; onToggled: console.log("Magnification:", checked) }
        }

        SettingsRow {
            rowLabel:    "Magnification scale"
            rowSubtitle: "Maximum zoom factor when hovering."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: magSlider
                    width:    140
                    from:     1.0
                    to:       2.0
                    value:    1.2
                    stepSize: 0.05
                }

                Text {
                    text:           "×" + magSlider.value.toFixed(2)
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          40
                }
            }
        }
    }

    // ── Behaviour ─────────────────────────────────────────────
    SettingsSection {
        label: "Behaviour"

        SettingsRow {
            rowLabel:    "Show running indicators"
            rowSubtitle: "Dot below icons of running applications."
            NxToggle { checked: true; onToggled: console.log("Running dots:", checked) }
        }

        SettingsRow {
            rowLabel:    "Show only pinned apps"
            rowSubtitle: "Hide unpinned running apps from the dock."
            NxToggle { checked: false; onToggled: console.log("Pinned only:", checked) }
        }

        SettingsRow {
            rowLabel:    "Bounce on launch"
            rowSubtitle: "Animate icon while application is loading."
            NxToggle { checked: true; onToggled: console.log("Bounce:", checked) }
        }
    }
}
