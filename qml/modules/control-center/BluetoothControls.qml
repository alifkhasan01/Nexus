import QtQuick
import QtQuick.Layouts
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// BluetoothControls — device list with connect/disconnect
Column {
    spacing: Theme.spacingMd

    RowLayout {
        width: parent.width

        Text {
            text:           "Bluetooth"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeBodySmall
            font.weight:    Theme.weightSemibold
            color:          Theme.textSecondary
        }

        Item { Layout.fillWidth: true }

        NxButton {
            text:    BluetoothService.discovering ? "Scanning…" : "Scan"
            variant: NxButton.Variant.Ghost
            implicitHeight: 26
            enabled: BluetoothService.powered
            loading: BluetoothService.discovering
            onClicked: BluetoothService.discovering
                ? BluetoothService.stopDiscovery()
                : BluetoothService.startDiscovery()
        }
    }

    // Device list
    Repeater {
        model: BluetoothService.devices

        delegate: RowLayout {
            required property var modelData
            width: parent.width
            height: 40

            Image {
                width: Theme.iconMd; height: Theme.iconMd
                source: "image://theme/" + modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text:           modelData.name
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBodySmall
                    font.weight:    Theme.weightMedium
                    color:          modelData.connected ? Theme.accent : Theme.text
                }
                Text {
                    text:           modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                }
            }

            NxButton {
                text:    modelData.connected ? "Disconnect" : "Connect"
                variant: modelData.connected
                    ? NxButton.Variant.Ghost : NxButton.Variant.Secondary
                implicitHeight: 26
                onClicked: modelData.connected
                    ? BluetoothService.disconnectDevice(modelData.address)
                    : BluetoothService.connectDevice(modelData.address)
            }
        }
    }

    Text {
        visible: BluetoothService.devices.length === 0 && BluetoothService.powered
        text:    "No devices found. Try scanning."
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.sizeCaption
        color:   Theme.textDisabled
    }

    Text {
        visible: !BluetoothService.powered
        text:    "Bluetooth is off"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.sizeCaption
        color:   Theme.textDisabled
    }
}
