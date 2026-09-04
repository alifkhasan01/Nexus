import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// NotificationCenter — slide-in panel from top-right
// Shows grouped notifications with dismiss + clear all
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var  screen
    property bool          visible: false
    signal close()

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.OnDemand
    WlrLayershell.anchors: WlrAnchors { top: true; right: true }

    implicitWidth:  360
    implicitHeight: screen.height
    color: "transparent"

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
    }

    // Scrim
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        TapHandler { onTapped: root.close() }
    }

    // ── Panel ────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            top:   parent.top
            right: parent.right
            topMargin:   Theme.barHeight + Theme.spacingSm
            rightMargin: Theme.spacingSm
        }
        width:   360
        height:  Math.min(
            headerRow.height + notifList.contentHeight + Theme.spacingLg * 3,
            root.screen.height - Theme.barHeight - Theme.spacingLg * 2
        )
        radius:  Theme.radiusXl
        color:   Theme.surface
        opacity: Theme.glassOpacity + 0.05
        border.color: Theme.border
        border.width: 1
        clip: true

        transform: Translate {
            y: root.visible ? 0 : -20
            Behavior on y {
                enabled: !Theme.reducedMotion
                NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
            }
        }

        // Top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Theme.borderSubtle; radius: parent.radius
        }

        // ── Header ───────────────────────────────────────────
        RowLayout {
            id: headerRow
            anchors {
                top:   parent.top
                left:  parent.left
                right: parent.right
                margins: Theme.spacingLg
            }
            height: 44

            Text {
                text:           "Notifications"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeSubtitle
                font.weight:    Theme.weightSemibold
                color:          Theme.text
                Layout.fillWidth: true
            }

            Text {
                text:           notifServer.notifications.length + " new"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeCaption
                color:          Theme.textSecondary
                visible:        notifServer.notifications.length > 0
            }

            NxButton {
                text:    "Clear all"
                variant: NxButton.Variant.Ghost
                implicitHeight: 28
                visible: notifServer.notifications.length > 0
                onClicked: {
                    // Dismiss all notifications
                    for (var i = notifServer.notifications.length - 1; i >= 0; --i) {
                        notifServer.notifications[i].expire()
                    }
                }
            }
        }

        // ── List ─────────────────────────────────────────────
        ListView {
            id: notifList
            anchors {
                top:         headerRow.bottom
                left:        parent.left
                right:       parent.right
                bottom:      parent.bottom
                margins:     Theme.spacingMd
                topMargin:   Theme.spacingSm
            }
            clip:          true
            spacing:       Theme.spacingSm
            model:         notifServer.notifications

            // Newest first
            verticalLayoutDirection: ListView.BottomToTop

            delegate: NotificationItem {
                required property var modelData
                width:        notifList.width
                notification: modelData
            }

            // Empty state
            Item {
                anchors.centerIn: parent
                visible: notifList.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingMd

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Theme.iconXl; height: Theme.iconXl
                        source: "image://theme/notification-symbolic"
                        opacity: 0.2
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           "No notifications"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeBody
                        color:          Theme.textDisabled
                    }
                }
            }
        }
    }

    // ── Notification server ───────────────────────────────────
    // Quickshell handles the freedesktop notification daemon
    NotificationServer {
        id: notifServer
        keepOnReload: true
    }
}
