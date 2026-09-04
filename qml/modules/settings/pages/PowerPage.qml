import QtQuick
import QtQuick.Layouts
import "../"
import "../../../theme"
import "../../../components"
import Nexus.Services 1.0

// ─────────────────────────────────────────────────────────────
// PowerPage — idle, suspend, screen-off, and session actions
// ─────────────────────────────────────────────────────────────
SettingsPage {
    pageTitle:    "Power"
    pageSubtitle: "Sleep, screen timeout, and session management."

    // ── Power actions ─────────────────────────────────────────
    SettingsSection {
        label: "Session Actions"

        SettingsRow {
            rowLabel:    "Lock screen"
            rowSubtitle: "Lock the session immediately."

            NxButton {
                text:    "Lock"
                variant: NxButton.Variant.Secondary
                implicitHeight: 30
                onClicked: PowerService.lock()
            }
        }

        SettingsRow {
            rowLabel:    "Log out"
            rowSubtitle: "End the current Wayland session."

            NxButton {
                text:    "Log out"
                variant: NxButton.Variant.Secondary
                implicitHeight: 30
                onClicked: PowerService.logout()
            }
        }

        SettingsRow {
            rowLabel:    "Suspend"
            rowSubtitle: "Suspend the system to RAM."

            NxButton {
                text:    "Suspend"
                variant: NxButton.Variant.Secondary
                implicitHeight: 30
                onClicked: PowerService.suspend()
            }
        }

        SettingsRow {
            rowLabel:    "Reboot"
            rowSubtitle: "Restart the system."

            NxButton {
                text:    "Reboot"
                variant: NxButton.Variant.Secondary
                implicitHeight: 30
                onClicked: PowerService.reboot()
            }
        }

        SettingsRow {
            rowLabel:    "Shut down"
            rowSubtitle: "Power off the system."

            NxButton {
                text:    "Shut down"
                variant: NxButton.Variant.Destructive
                implicitHeight: 30
                onClicked: PowerService.shutdown()
            }
        }
    }

    // ── Screen ────────────────────────────────────────────────
    SettingsSection {
        label: "Screen"

        SettingsRow {
            rowLabel:    "Turn off screen after"
            rowSubtitle: "Blank the display after this period of inactivity."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: screenOffSlider
                    width:    140
                    from:     1
                    to:       30
                    value:    5
                    stepSize: 1
                }

                Text {
                    text:           screenOffSlider.value + " min"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          44
                }
            }
        }

        SettingsRow {
            rowLabel:    "Dim before blanking"
            rowSubtitle: "Gradually reduce brightness before the screen turns off."
            NxToggle { checked: true; onToggled: console.log("Dim:", checked) }
        }
    }

    // ── Idle / suspend ────────────────────────────────────────
    SettingsSection {
        label: "Idle"

        SettingsRow {
            rowLabel:    "Suspend after"
            rowSubtitle: "Suspend to RAM after this period of inactivity. 0 = never."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: suspendSlider
                    width:    140
                    from:     0
                    to:       60
                    value:    15
                    stepSize: 5
                }

                Text {
                    text:           suspendSlider.value === 0 ? "Never"
                                    : suspendSlider.value + " min"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          44
                }
            }
        }

        SettingsRow {
            rowLabel:    "Lock on suspend"
            rowSubtitle: "Require authentication when waking from suspend."
            NxToggle { checked: true; onToggled: console.log("Lock on suspend:", checked) }
        }

        SettingsRow {
            rowLabel:    "Lock screen after"
            rowSubtitle: "Automatically lock after this idle period."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: lockSlider
                    width:    140
                    from:     0
                    to:       30
                    value:    5
                    stepSize: 1
                }

                Text {
                    text:           lockSlider.value === 0 ? "Never"
                                    : lockSlider.value + " min"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          44
                }
            }
        }
    }

    // ── Battery ───────────────────────────────────────────────
    SettingsSection {
        label: "Battery"
        visible: BatteryService.present

        SettingsRow {
            rowLabel: "Show battery percentage"
            NxToggle { checked: true; onToggled: console.log("Battery %:", checked) }
        }

        SettingsRow {
            rowLabel:    "Low battery threshold"
            rowSubtitle: "Warn when battery falls below this level."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: lowBatSlider
                    width:    140
                    from:     5
                    to:       30
                    value:    20
                    stepSize: 5
                }

                Text {
                    text:           lowBatSlider.value + "%"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          32
                }
            }
        }

        SettingsRow {
            rowLabel:    "Critical battery threshold"
            rowSubtitle: "Suspend or hibernate when battery falls below this level."

            RowLayout {
                spacing: Theme.spacingSm

                NxSlider {
                    id: critBatSlider
                    width:    140
                    from:     3
                    to:       15
                    value:    5
                    stepSize: 1
                }

                Text {
                    text:           critBatSlider.value + "%"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    width:          32
                }
            }
        }
    }
}
