import QtQuick
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// BrightnessControl — single brightness slider row
Row {
    spacing: Theme.spacingSm

    Image {
        anchors.verticalCenter: parent.verticalCenter
        width:  Theme.iconMd; height: Theme.iconMd
        source: "image://theme/display-brightness"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    NxSlider {
        anchors.verticalCenter: parent.verticalCenter
        width:    parent.width - Theme.iconMd - Theme.spacingSm - 44
        from:     0.0;  to: 1.0
        value:    BrightnessService.percent
        fillColor: "#f59e0b"
        onMoved:  BrightnessService.setPercent(value)
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width:          40
        text:           Math.round(BrightnessService.percent * 100) + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.sizeCaption
        font.weight:    Theme.weightMedium
        color:          Theme.textSecondary
        horizontalAlignment: Text.AlignRight
    }
}
