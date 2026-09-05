import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// Launcher — application search overlay
//
// Keyboard-first: Arrow keys navigate, Enter launches,
// Escape closes. Uses AppIndexer.search() for fuzzy results.
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var  screen
    property bool          visible: false
    signal close()

    WlrLayershell.layer:              WlrLayer.Overlay
    WlrLayershell.exclusiveZone:      -1
    WlrLayershell.keyboardInteractivity: WlrKeyboardInteractivity.Exclusive
    WlrLayershell.anchors: WlrAnchors { top: true; left: true; right: true; bottom: true }

    implicitWidth:  screen.width
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
        color:        Theme.scrim
        opacity:      0.45
        TapHandler { onTapped: root.close() }
    }

    // ── Panel ────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            top:              parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin:        screen.height * 0.12
        }
        width:   560
        height:  Math.min(contentCol.implicitHeight + Theme.spacingLg * 2, screen.height * 0.65)
        radius:  Theme.radiusXl
        color:   Theme.surface
        opacity: Theme.glassOpacity
        border.color: Theme.border
        border.width: 1
        clip: true

        // Scale-in animation
        scale: root.visible ? 1.0 : 0.94
        Behavior on scale {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
        }

        // Top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color:  Theme.borderSubtle
            radius: parent.radius
        }

        Column {
            id: contentCol
            anchors {
                top:   parent.top
                left:  parent.left
                right: parent.right
            }

            // Search input area
            LauncherSearch {
                id: searchBar
                width: parent.width
                onTextChanged: resultsView.refresh(text)
                onMoveDown:    resultsView.moveSelection(1)
                onMoveUp:      resultsView.moveSelection(-1)
                onConfirm:     resultsView.launchSelected()
                onDismissed:   root.close()
            }

            // Divider
            NxSeparator {
                width:  parent.width
                height: 1
            }

            // Results list
            LauncherResult {
                id: resultsView
                width:      parent.width
                maxHeight:  screen.height * 0.45
                searchText: searchBar.text
                onAppLaunched: root.close()
            }
        }

        // Keyboard handler while panel is visible
        Keys.onEscapePressed: root.close()
    }

    // Focus search on open
    onVisibleChanged: {
        if (visible) {
            searchBar.clear()
            searchBar.forceActiveFocus()
        }
    }
}
