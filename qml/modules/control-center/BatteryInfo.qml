import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// BatteryInfo — compact battery status row
RowLayout {
    spacing: Theme.spacingMd

    Image {
        width:  Theme.iconMd; height: Theme.iconMd
        source: "image://theme/" + BatteryService.iconName()
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Column {
        Layout.fillWidth: true
        spacing: 2

        Text {
            text: {
                var s = BatteryService.state
                if (s === "charging")    return "Charging — " + BatteryService.percentage + "%"
                if (s === "full")        return "Fully charged"
                return BatteryService.percentage + "% remaining"
            }
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeBodySmall
            font.weight:    Theme.weightMedium
            color:          Theme.text
        }

        Text {
            visible: BatteryService.timeToEmpty > 0 || BatteryService.timeToFull > 0
            text: {
                var secs = BatteryService.charging
                    ? BatteryService.timeToFull : BatteryService.timeToEmpty
                if (secs <= 0) return ""
                var h = Math.floor(secs / 3600)
                var m = Math.floor((secs % 3600) / 60)
                var label = h > 0 ? h + "h " : ""
                label += m + "m"
                return BatteryService.charging ? label + " until full" : label + " remaining"
            }
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            color:          Theme.textSecondary
        }
    }

    NxProgressBar {
        width:  80
        height: 6
        value:  BatteryService.percentage / 100.0
        fillColor: BatteryService.percentage <= 20 ? Theme.error
                 : BatteryService.charging         ? Theme.success
                 : Theme.accent
    }
}
