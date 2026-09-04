import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// StatusIcons — battery, network, volume, brightness icons
// Clicking anywhere opens Control Center
Item {
    id: root

    signal triggerControlCenter()

    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs

        // ── Network ─────────────────────────────────────────
        Image {
            width:  Theme.iconSm
            height: Theme.iconSm
            source: {
                if (!NetworkService.wifiEnabled)   return "image://theme/network-wireless-disabled"
                if (!NetworkService.connected)     return "image://theme/network-wireless-offline"
                var s = NetworkService.signalStrength
                if (s > 75)  return "image://theme/network-wireless-signal-excellent"
                if (s > 50)  return "image://theme/network-wireless-signal-good"
                if (s > 25)  return "image://theme/network-wireless-signal-ok"
                return "image://theme/network-wireless-signal-weak"
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        // ── Volume ───────────────────────────────────────────
        Image {
            width:  Theme.iconSm
            height: Theme.iconSm
            source: {
                if (AudioService.muted || AudioService.volume === 0)
                    return "image://theme/audio-volume-muted"
                if (AudioService.volume < 33)
                    return "image://theme/audio-volume-low"
                if (AudioService.volume < 66)
                    return "image://theme/audio-volume-medium"
                return "image://theme/audio-volume-high"
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        // ── Battery ──────────────────────────────────────────
        Row {
            spacing: Theme.spacingXxs
            visible: BatteryService.present

            Image {
                anchors.verticalCenter: parent.verticalCenter
                width:  Theme.iconSm
                height: Theme.iconSm
                source: "image://theme/" + BatteryService.iconName()
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           BatteryService.percentage + "%"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                font.weight:    Theme.weightMedium
                color: {
                    if (BatteryService.percentage <= 15 && !BatteryService.charging)
                        return Theme.error
                    if (BatteryService.percentage <= 30 && !BatteryService.charging)
                        return Theme.warning
                    return Theme.textSecondary
                }
            }
        }
    }

    // Click opens control center
    TapHandler {
        onTapped: root.triggerControlCenter()
    }
    HoverHandler { id: hov }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color: hov.hovered ? Theme.surfaceHighlight : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }
}
