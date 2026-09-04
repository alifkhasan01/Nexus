import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// NotificationBanner — transient popup for a single notification
// Shown at top-center for ~5 seconds then dismissed
Item {
    id: root

    required property var notification
    signal dismissed()

    implicitWidth:  380
    implicitHeight: contentLayout.implicitHeight + Theme.spacingLg

    // Auto-dismiss
    Timer {
        id: dismissTimer
        interval: 5000
        running:  true
        onTriggered: root.dismissed()
    }

    // Slide-down + fade in
    y: visible ? 0 : -implicitHeight - Theme.spacingMd
    opacity: 1.0
    Behavior on y {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
    }

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.surface
        opacity:      Theme.glassOpacity + 0.1
        border.color: Theme.border
        border.width: 1

        // Urgency accent
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width:  3
            radius: Theme.radiusMd
            color: {
                var u = root.notification.urgency
                if (u === 2) return Theme.error
                return Theme.accent
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors {
                fill:        parent
                margins:     Theme.spacingMd
                leftMargin:  Theme.spacingMd + 6
            }
            spacing: Theme.spacingXs

            RowLayout {
                Layout.fillWidth: true

                Image {
                    width: Theme.iconSm; height: Theme.iconSm
                    source: root.notification.appIcon !== ""
                        ? root.notification.appIcon
                        : "image://theme/" + root.notification.appName.toLowerCase()
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: if (status === Image.Error) source = "image://theme/dialog-information"
                }

                Text {
                    text:           root.notification.appName
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    font.weight:    Theme.weightSemibold
                    color:          Theme.textSecondary
                    Layout.fillWidth: true
                }

                NxIconButton {
                    iconName:   "image://theme/window-close"
                    iconSize:   Theme.iconSm - 2
                    buttonSize: 20
                    onClicked: {
                        dismissTimer.stop()
                        root.dismissed()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text:           root.notification.summary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBodySmall
                font.weight:    Theme.weightSemibold
                color:          Theme.text
                wrapMode:       Text.Wrap
                maximumLineCount: 1
                elide:          Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text:           root.notification.body
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBodySmall
                color:          Theme.textSecondary
                wrapMode:       Text.Wrap
                maximumLineCount: 2
                elide:          Text.ElideRight
                visible:        text !== ""
            }
        }
    }

    // Swipe-up to dismiss
    DragHandler {
        id: drag
        yAxis.minimum: -root.implicitHeight * 2
        yAxis.maximum: 0
        onActiveChanged: {
            if (!drag.active && drag.centroid.position.y < -root.implicitHeight * 0.4) {
                root.dismissed()
            }
        }
    }
}
