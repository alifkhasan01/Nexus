import QtQuick
import "../theme"

// NxCard — elevated surface container
Item {
    id: root

    property color  cardColor:   Theme.surface
    property int    cardRadius:  Theme.radiusMd
    property int    cardPadding: Theme.spacingLg
    property bool   bordered:    false
    property bool   interactive: false  // adds hover/press states

    default property alias content: contentWrapper.data

    implicitWidth:  contentWrapper.implicitWidth  + cardPadding * 2
    implicitHeight: contentWrapper.implicitHeight + cardPadding * 2

    // ── Background ──────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius:       root.cardRadius
        color:        root.interactive && hoverArea.containsMouse
            ? Qt.lighter(root.cardColor, 1.06)
            : root.cardColor

        border.color: root.bordered ? Theme.border : "transparent"
        border.width: Theme.borderThin

        Behavior on color {
            enabled: !Theme.reducedMotion
            ColorAnimation { duration: Theme.durationFast }
        }
    }

    // ── Content slot ────────────────────────────────────────
    Item {
        id: contentWrapper
        anchors {
            fill:    parent
            margins: root.cardPadding
        }
    }

    // ── Optional interactivity ───────────────────────────────
    HoverHandler {
        id: hoverArea
        enabled: root.interactive
    }

    scale: root.interactive && hoverArea.containsMouse
        ? 1.01 : 1.0
    Behavior on scale {
        enabled: !Theme.reducedMotion && root.interactive
        NumberAnimation { duration: Theme.durationFast }
    }
}
