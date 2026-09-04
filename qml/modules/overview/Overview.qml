import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// Overview — Mission Control-style workspace + window overview
//
// Layout:
//   Top row: workspace thumbnails (click to switch)
//   Main area: window thumbnails for active workspace
//              (click to focus, X to close, drag to move WS)
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

    // Refresh compositor data when opened
    onVisibleChanged: {
        if (visible) CompositorService.refresh()
    }

    // ── Scrim ────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.scrim
        opacity:      0.60
        TapHandler { onTapped: root.close() }
    }

    // ── Selected workspace ───────────────────────────────────
    property int selectedWorkspace: CompositorService.activeWorkspace

    // ── Main layout ──────────────────────────────────────────
    Column {
        anchors {
            fill:        parent
            margins:     Theme.spacingXl
            topMargin:   Theme.barHeight + Theme.spacingXl
        }
        spacing: Theme.spacingXl

        // ── Workspace strip ──────────────────────────────────
        Item {
            width:  parent.width
            height: 88

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingMd

                Repeater {
                    model: CompositorService.workspaces

                    delegate: WorkspaceThumb {
                        required property var modelData
                        workspaceId:   modelData.id
                        workspaceName: modelData.name !== "" ? modelData.name : String(modelData.id)
                        windowCount:   modelData.windows
                        active:        modelData.id === root.selectedWorkspace

                        onClicked: {
                            root.selectedWorkspace = modelData.id
                            CompositorService.switchWorkspace(modelData.id)
                        }
                    }
                }
            }
        }

        // ── Window grid ──────────────────────────────────────
        Item {
            width:  parent.width
            height: parent.height - 88 - Theme.spacingXl

            // Windows for selected workspace
            property var wsWindows: {
                var wins = []
                for (var i = 0; i < CompositorService.windows.length; ++i) {
                    var w = CompositorService.windows[i]
                    if (w.workspaceId === root.selectedWorkspace) wins.push(w)
                }
                return wins
            }

            // Compute grid columns based on count
            property int cols: {
                var n = wsWindows.length
                if (n <= 1) return 1
                if (n <= 4) return 2
                if (n <= 9) return 3
                return 4
            }

            Flow {
                anchors.centerIn: parent
                width:            parent.width
                spacing:          Theme.spacingMd

                Repeater {
                    model: parent.parent.wsWindows

                    delegate: WindowThumb {
                        required property var modelData

                        thumbWidth:  Math.floor((parent.width - (parent.parent.cols - 1) * Theme.spacingMd) / parent.parent.cols)
                        thumbHeight: Math.round(thumbWidth * 0.5625)  // 16:9
                        windowTitle:  modelData.title
                        windowClass:  modelData.appClass
                        isFocused:    modelData.focused
                        isFloating:   modelData.floating

                        onClicked: {
                            CompositorService.focusWindow(modelData.address)
                            root.close()
                        }
                        onCloseRequested: {
                            CompositorService.closeWindow(modelData.address)
                        }
                    }
                }
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingMd
                visible: parent.wsWindows.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Empty workspace"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeTitle
                    color:          Theme.textDisabled
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "No open windows"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBody
                    color:          Theme.textDisabled
                    opacity:        0.6
                }
            }
        }
    }

    Keys.onEscapePressed: root.close()
}
