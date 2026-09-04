import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "../../theme"

// ─────────────────────────────────────────────────────────────
// Dock — bottom application dock
//
// Shows:
//   - Pinned apps (from config / hardcoded defaults)
//   - Running apps (from CompositorService.windows)
//   - Separator between pinned and running-only apps
//
// Auto-hide: slides out of view when a window occupies the
// bottom edge; slides in when the cursor approaches.
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var screen

    // ── Layer-shell ──────────────────────────────────────────
    WlrLayershell.layer:   WlrLayer.Bottom
    WlrLayershell.anchors: WlrAnchors { bottom: true; left: true; right: true }
    WlrLayershell.exclusiveZone: autoHide ? 0 : dockHeight + Theme.spacingMd

    implicitWidth:  screen.width
    implicitHeight: dockHeight + Theme.spacingMd * 2
    color: "transparent"

    // ── Auto-hide ────────────────────────────────────────────
    property bool autoHide: true
    property bool revealed: !autoHide || cursorNearBottom

    // Detect cursor near bottom edge via global mouse position
    // (Quickshell provides GlobalMousePosition or we use a HoverHandler trick)
    property bool cursorNearBottom: false

    // Slide animation
    property int dockHeight: Theme.dockIconSize + Theme.dockPadding * 2

    transform: Translate {
        y: root.revealed ? 0 : dockHeight + Theme.spacingMd * 2
        Behavior on y {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
        }
    }

    // Edge detector — a thin invisible area at screen bottom
    // triggers reveal when cursor enters
    PanelWindow {
        id: edgeDetector
        screen: root.screen
        WlrLayershell.layer:   WlrLayer.Overlay
        WlrLayershell.anchors: WlrAnchors { bottom: true; left: true; right: true }
        WlrLayershell.exclusiveZone: -1
        implicitWidth:  screen.width
        implicitHeight: 4
        color: "transparent"

        HoverHandler {
            onHoveredChanged: root.cursorNearBottom = hovered
        }
    }

    // ── Pinned apps model ────────────────────────────────────
    // TODO: load from config file; using defaults for now
    ListModel {
        id: pinnedModel
        ListElement { appId: "org.gnome.Nautilus";   icon: "system-file-manager" }
        ListElement { appId: "firefox";               icon: "firefox" }
        ListElement { appId: "org.gnome.Terminal";    icon: "utilities-terminal" }
        ListElement { appId: "code";                  icon: "code" }
        ListElement { appId: "discord";               icon: "discord" }
        ListElement { appId: "spotify";               icon: "spotify" }
    }

    // ── Running windows not in pinned list ───────────────────
    property var runningClasses: {
        var classes = {}
        for (var i = 0; i < CompositorService.windows.length; ++i) {
            var cls = CompositorService.windows[i].appClass.toLowerCase()
            if (cls) classes[cls] = true
        }
        return classes
    }

    property bool hasRunningExtra: {
        for (var cls in runningClasses) {
            var found = false
            for (var i = 0; i < pinnedModel.count; ++i) {
                if (pinnedModel.get(i).appId.toLowerCase() === cls) { found = true; break }
            }
            if (!found) return true
        }
        return false
    }

    // ── Dock panel ───────────────────────────────────────────
    Rectangle {
        id: dockPanel
        anchors {
            bottom:           parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin:     Theme.spacingMd
        }
        width:  dockRow.implicitWidth + Theme.dockPadding * 2
        height: root.dockHeight
        radius: Theme.radiusXl
        color:  Theme.surface
        opacity: Theme.glassOpacity
        border.color: Theme.border
        border.width: 1

        // Subtle top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color:  Theme.borderSubtle
            radius: parent.radius
        }

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: Theme.spacingXs

            // Pinned apps
            Repeater {
                model: pinnedModel
                DockItem {
                    appId:      modelData.appId
                    iconName:   modelData.icon
                    pinned:     true
                    running:    root.runningClasses[modelData.appId.toLowerCase()] === true
                    focused:    CompositorService.activeAppClass.toLowerCase() === modelData.appId.toLowerCase()
                    onClicked: {
                        if (running) {
                            // Focus the first matching window
                            for (var i = 0; i < CompositorService.windows.length; ++i) {
                                if (CompositorService.windows[i].appClass.toLowerCase() === modelData.appId.toLowerCase()) {
                                    CompositorService.focusWindow(CompositorService.windows[i].address)
                                    break
                                }
                            }
                        } else {
                            AppIndexer.launch(modelData.appId)
                        }
                    }
                }
            }

            // Separator between pinned and extra running apps
            DockSeparator { visible: root.hasRunningExtra }

            // Extra running apps (not pinned)
            Repeater {
                model: {
                    var extra = []
                    var seen  = {}
                    for (var i = 0; i < pinnedModel.count; ++i)
                        seen[pinnedModel.get(i).appId.toLowerCase()] = true
                    for (var j = 0; j < CompositorService.windows.length; ++j) {
                        var cls = CompositorService.windows[j].appClass.toLowerCase()
                        if (!seen[cls]) { seen[cls] = true; extra.push(cls) }
                    }
                    return extra
                }

                DockItem {
                    appId:    modelData
                    iconName: "image://theme/" + modelData
                    pinned:   false
                    running:  true
                    focused:  CompositorService.activeAppClass.toLowerCase() === modelData
                    onClicked: {
                        for (var i = 0; i < CompositorService.windows.length; ++i) {
                            if (CompositorService.windows[i].appClass.toLowerCase() === modelData) {
                                CompositorService.focusWindow(CompositorService.windows[i].address)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
