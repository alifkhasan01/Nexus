import QtQuick
import QtQuick.Controls.Basic as Controls
import "../theme"

// NxButton — primary, secondary and ghost variants
Controls.Button {
    id: root

    // ── Public API ──────────────────────────────────────────
    enum Variant { Primary, Secondary, Ghost, Destructive }
    property int variant: NxButton.Variant.Primary

    property color customBackground: "transparent"
    property bool  loading: false

    // ── Sizing ──────────────────────────────────────────────
    implicitHeight: 34
    implicitWidth:  contentItem.implicitWidth + Theme.spacingLg * 2

    horizontalPadding: Theme.spacingLg
    verticalPadding:   Theme.spacingSm

    // ── Background ──────────────────────────────────────────
    background: Rectangle {
        radius: Theme.radiusSm

        color: {
            if (!root.enabled)
                return Theme.surfaceHighlight
            if (root.pressed)
                return resolvedPressed
            if (root.hovered)
                return resolvedHover
            return resolvedBase
        }

        border.color: root.variant === NxButton.Variant.Secondary ? Theme.border : "transparent"
        border.width: Theme.borderThin

        readonly property color resolvedBase: {
            switch (root.variant) {
            case NxButton.Variant.Primary:      return Theme.accent
            case NxButton.Variant.Secondary:    return Theme.surface
            case NxButton.Variant.Ghost:        return "transparent"
            case NxButton.Variant.Destructive:  return Theme.error
            default:                            return Theme.accent
            }
        }
        readonly property color resolvedHover: {
            switch (root.variant) {
            case NxButton.Variant.Primary:      return Theme.accentHover
            case NxButton.Variant.Secondary:    return Theme.surfaceElevated
            case NxButton.Variant.Ghost:        return Theme.surfaceHighlight
            case NxButton.Variant.Destructive:  return Qt.lighter(Theme.error, 1.15)
            default:                            return Theme.accentHover
            }
        }
        readonly property color resolvedPressed: {
            switch (root.variant) {
            case NxButton.Variant.Primary:      return Theme.accentPressed
            case NxButton.Variant.Secondary:    return Theme.border
            case NxButton.Variant.Ghost:        return Theme.border
            case NxButton.Variant.Destructive:  return Qt.darker(Theme.error, 1.15)
            default:                            return Theme.accentPressed
            }
        }

        Behavior on color {
            enabled: !Theme.reducedMotion
            ColorAnimation { duration: Theme.durationFast; easing.type: Theme.easingStandard }
        }
    }

    // ── Label ───────────────────────────────────────────────
    contentItem: Text {
        text:              root.text
        font.family:       Theme.fontFamily
        font.pixelSize:    Theme.sizeBody
        font.weight:       Theme.weightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        color: root.enabled
            ? (root.variant === NxButton.Variant.Secondary || root.variant === NxButton.Variant.Ghost
                ? Theme.text
                : "#ffffff")
            : Theme.textDisabled
        opacity: root.loading ? 0.0 : 1.0
    }

    // ── Focus ring ───────────────────────────────────────────
    Rectangle {
        anchors.fill:   parent
        anchors.margins: -2
        radius:         Theme.radiusSm + 2
        color:          "transparent"
        border.color:   Theme.borderFocus
        border.width:   2
        visible:        root.activeFocus
        opacity:        0.8
    }

    // ── Loading spinner placeholder ──────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:  16; height: 16
        radius: 8
        color:  "transparent"
        border.color: "#ffffff"
        border.width: 2
        visible: root.loading
        RotationAnimator on rotation {
            running: root.loading
            from: 0; to: 360
            duration: 800
            loops: Animation.Infinite
        }
    }

    // ── Scale feedback ───────────────────────────────────────
    scale: root.pressed ? 0.96 : 1.0
    Behavior on scale {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingStandard }
    }
}
