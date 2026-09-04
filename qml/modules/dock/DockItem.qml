import QtQuick
import "../../theme"
import "../../components"

// DockItem — single icon in the dock with hover magnification,
// running indicator, and focus highlight
Item {
    id: root

    property string appId:    ""
    property string iconName: ""
    property bool   pinned:   false
    property bool   running:  false
    property bool   focused:  false

    signal clicked()

    // Base size; grows on hover
    property real baseSize: Theme.dockIconSize
    property real hoverScale: 1.20

    implicitWidth:  baseSize + Theme.spacingXs
    implicitHeight: baseSize + Theme.spacingSm + 6  // room for dot

    HoverHandler { id: hov }

    // Magnification
    property real currentScale: hov.hovered ? hoverScale : 1.0
    Behavior on currentScale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingDecelerate }
    }

    // Icon container
    Rectangle {
        id: iconBg
        anchors {
            horizontalCenter: parent.horizontalCenter
            top:              parent.top
            topMargin:        Theme.spacingXs
        }
        width:  root.baseSize * root.currentScale
        height: root.baseSize * root.currentScale
        radius: (root.baseSize * root.currentScale) * 0.22
        color:  root.focused ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                             : (hov.hovered ? Theme.surfaceHighlight : "transparent")

        Behavior on width  { NumberAnimation { duration: Theme.durationFast } }
        Behavior on height { NumberAnimation { duration: Theme.durationFast } }

        Image {
            anchors.fill:   parent
            anchors.margins: 3
            source:   root.iconName.startsWith("image://") ? root.iconName
                      : "image://theme/" + root.iconName
            fillMode: Image.PreserveAspectFit
            smooth:   true
            mipmap:   true

            // Fallback icon
            onStatusChanged: {
                if (status === Image.Error) {
                    source = "image://theme/application-default-icon"
                }
            }
        }
    }

    // Running dot indicator
    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom:           parent.bottom
            bottomMargin:     2
        }
        width:  root.focused ? 8 : 4
        height: 4
        radius: 2
        color:  root.focused ? Theme.accent : Theme.textSecondary
        visible: root.running

        Behavior on width { NumberAnimation { duration: Theme.durationFast } }
        Behavior on color { ColorAnimation  { duration: Theme.durationFast } }
    }

    // Tooltip
    NxTooltip { text: root.appId }

    TapHandler {
        onTapped: root.clicked()
    }
}
