import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// NotificationItem — single notification card in the center
Item {
    id: root

    required property var notification

    implicitHeight: card.implicitHeight
    implicitWidth:  parent ? parent.width : 320

    HoverHandler { id: hov }

    // Slide-in animation
    opacity: 0
    Component.onCompleted: {
        if (!Theme.reducedMotion) {
            slideIn.running = true
        } else {
            opacity = 1.0
        }
    }
    SequentialAnimation {
        id: slideIn
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: Theme.durationNormal }
    }

    Rectangle {
        id: card
        anchors { left: parent.left; right: parent.right }
        radius:  Theme.radiusMd
        color:   hov.hovered ? Theme.surfaceElevated : Theme.surfaceHighlight
        border.color: Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        // Urgency accent
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width:  3
            radius: Theme.radiusMd
            color: {
                var u = root.notification ? root.notification.urgency : 1
                if (u === 2) return Theme.error
                if (u === 0) return Theme.textDisabled
                return Theme.accent
            }
        }

        ColumnLayout {
            anchors {
                fill:           parent
                margins:        Theme.spacingMd
                leftMargin:     Theme.spacingMd + 6  // account for urgency bar
            }
            spacing: Theme.spacingXs

            // ── Header row ───────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                // App icon
                Image {
                    width:  Theme.iconSm; height: Theme.iconSm
                    source: root.notification ? (root.notification.appIcon !== ""
                        ? root.notification.appIcon
                        : "image://theme/" + root.notification.appName.toLowerCase())
                        : "image://theme/dialog-information"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    onStatusChanged: if (status === Image.Error) source = "image://theme/dialog-information"
                }

                // App name
                Text {
                    text:           root.notification ? root.notification.appName : ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    font.weight:    Theme.weightSemibold
                    color:          Theme.textSecondary
                    Layout.fillWidth: true
                    elide:          Text.ElideRight
                }

                // Timestamp
                Text {
                    text: {
                        if (!root.notification) return ""
                        var d = new Date(root.notification.time)
                        return d.toLocaleTimeString(Qt.locale(), "HH:mm")
                    }
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textDisabled
                }

                // Dismiss
                NxIconButton {
                    iconName:   "image://theme/window-close"
                    iconSize:   Theme.iconSm - 2
                    buttonSize: 20
                    visible:    hov.hovered
                    onClicked: {
                        if (root.notification) root.notification.expire()
                    }
                }
            }

            // ── Summary ──────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text:           root.notification ? root.notification.summary : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBodySmall
                font.weight:    Theme.weightSemibold
                color:          Theme.text
                wrapMode:       Text.Wrap
                maximumLineCount: 2
                elide:          Text.ElideRight
                visible:        text !== ""
            }

            // ── Body ─────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text:           root.notification ? root.notification.body : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBodySmall
                color:          Theme.textSecondary
                wrapMode:       Text.Wrap
                maximumLineCount: 4
                elide:          Text.ElideRight
                visible:        text !== ""
                topPadding:     text !== "" ? 0 : 0
            }

            // ── Actions ──────────────────────────────────────
            Row {
                spacing: Theme.spacingXs
                visible: root.notification && root.notification.actions.length > 0

                Repeater {
                    model: root.notification ? root.notification.actions : []

                    delegate: NxButton {
                        required property var modelData
                        text:    modelData.text
                        variant: NxButton.Variant.Secondary
                        implicitHeight: 26
                        onClicked: root.notification.invokeAction(modelData.identifier)
                    }
                }
            }
        }

        // Compute implicitHeight from layout
        implicitHeight: contentCol_inner.implicitHeight + Theme.spacingMd * 2

        // Inner height anchor helper
        Item {
            id: contentCol_inner
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.spacingMd }
            implicitHeight: childrenRect.height
        }
    }
}
