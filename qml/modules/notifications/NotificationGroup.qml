import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../theme"

// NotificationBannerLayer — per-screen floating banners
// (referenced in shell.qml as NotificationBannerLayer)
PanelWindow {
    id: root

    required property var screen

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.None
    WlrLayershell.anchors: WlrAnchors { top: true; right: true }

    implicitWidth:  400
    implicitHeight: Math.max(bannerCol.implicitHeight + Theme.barHeight + Theme.spacingMd, 1)
    color: "transparent"

    // Notification server — shared instance
    NotificationServer {
        id: notifServer
        keepOnReload: true

        onNotification: function(notif) {
            // Append to banner queue
            bannerModel.append({ notif: notif })
        }
    }

    ListModel {
        id: bannerModel
    }

    Column {
        id: bannerCol
        anchors {
            top:   parent.top
            right: parent.right
            topMargin:   Theme.barHeight + Theme.spacingMd
            rightMargin: Theme.spacingMd
        }
        spacing: Theme.spacingSm

        Repeater {
            model: bannerModel

            delegate: NotificationBanner {
                required property var  modelData
                required property int  index

                notification: modelData.notif

                onDismissed: bannerModel.remove(index)
            }
        }
    }
}
