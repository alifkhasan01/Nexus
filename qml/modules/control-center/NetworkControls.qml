import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// NetworkControls — connected SSID + signal strength + scan button
Column {
    spacing: Theme.spacingMd

    // Header row
    RowLayout {
        width: parent.width

        Text {
            text:           "Network"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeBodySmall
            font.weight:    Theme.weightSemibold
            color:          Theme.textSecondary
        }

        Item { Layout.fillWidth: true }

        NxButton {
            text:    "Scan"
            variant: NxButton.Variant.Ghost
            implicitHeight: 26
            onClicked: NetworkService.scanNetworks()
        }
    }

    // Connected network
    RowLayout {
        width: parent.width
        visible: NetworkService.connected

        Image {
            width:  Theme.iconMd; height: Theme.iconMd
            source: "image://theme/network-wireless-signal-excellent"
            fillMode: Image.PreserveAspectFit
        }

        Column {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text:           NetworkService.connectedSsid
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBodySmall
                font.weight:    Theme.weightMedium
                color:          Theme.text
            }
            Text {
                text:           "Connected · " + NetworkService.signalStrength + "%"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                color:          Theme.textSecondary
            }
        }

        NxButton {
            text:    "Disconnect"
            variant: NxButton.Variant.Ghost
            implicitHeight: 26
            onClicked: NetworkService.disconnectNetwork()
        }
    }

    // Disconnected state
    Text {
        visible:        !NetworkService.connected && NetworkService.wifiEnabled
        text:           "Not connected to Wi-Fi"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.sizeBodySmall
        color:          Theme.textDisabled
    }

    // Available networks list
    Column {
        width:   parent.width
        spacing: 2

        Repeater {
            model: NetworkService.networks

            delegate: RowLayout {
                required property var modelData
                width: parent.width
                height: 36

                Text {
                    text:           modelData.ssid
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBodySmall
                    color:          modelData.connected ? Theme.accent : Theme.text
                    Layout.fillWidth: true
                }

                Image {
                    width: Theme.iconSm; height: Theme.iconSm
                    source: modelData.secured ? "image://theme/network-wireless-encrypted" : ""
                    visible: modelData.secured
                    fillMode: Image.PreserveAspectFit
                }

                NxButton {
                    text:    modelData.connected ? "Connected" : "Connect"
                    variant: modelData.connected ? NxButton.Variant.Ghost : NxButton.Variant.Secondary
                    enabled: !modelData.connected
                    implicitHeight: 26
                    onClicked: NetworkService.connectNetwork(modelData.ssid)
                }
            }
        }
    }
}
