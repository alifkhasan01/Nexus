import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../components"
import "pages"

// ─────────────────────────────────────────────────────────────
// Settings — full-screen settings overlay
//
// Layout: two-column
//   Left:  SettingsSidebar (nav rail, 220 px)
//   Right: Loader showing the active SettingsPage
//
// Pages are identified by integer IDs defined in pageIndex.
// The sidebar model is built from that same index so they
// stay in sync automatically.
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
    color:          "transparent"

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        enabled: !Theme.reducedMotion
        NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
    }

    // ── Page registry ─────────────────────────────────────────
    // id must be unique; source is a relative QML url
    readonly property var pageIndex: [
        { id: 0, label: "Appearance",    icon: "preferences-desktop-theme",         section: "General",  source: "pages/AppearancePage.qml"    },
        { id: 1, label: "Bar",           icon: "preferences-system-windows",         section: "Shell",    source: "pages/BarPage.qml"           },
        { id: 2, label: "Dock",          icon: "preferences-system-windows-actions", section: "Shell",    source: "pages/DockPage.qml"          },
        { id: 3, label: "Notifications", icon: "preferences-desktop-notification",   section: "Shell",    source: "pages/NotificationsPage.qml" },
        { id: 4, label: "Power",         icon: "preferences-system-power",           section: "System",   source: "pages/PowerPage.qml"         },
    ]

    property int currentPageId: 0

    // ── Scrim ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.scrim
        opacity:      0.60
        TapHandler { onTapped: root.close() }
    }

    // ── Window shell ─────────────────────────────────────────
    Rectangle {
        id: window
        anchors {
            top:              parent.top
            left:             parent.left
            right:            parent.right
            bottom:           parent.bottom
            topMargin:        screen.height * 0.05
            leftMargin:       screen.width  * 0.10
            rightMargin:      screen.width  * 0.10
            bottomMargin:     screen.height * 0.05
        }
        radius:       Theme.radiusXl
        color:        Theme.background
        border.color: Theme.border
        border.width: 1
        clip:         true

        scale: root.visible ? 1.0 : 0.96
        Behavior on scale {
            enabled: !Theme.reducedMotion
            NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingDecelerate }
        }

        // Top highlight
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Theme.borderSubtle; radius: parent.radius
        }

        RowLayout {
            anchors.fill: parent
            spacing:      0

            // ── Sidebar ───────────────────────────────────────
            SettingsSidebar {
                Layout.fillHeight: true
                implicitWidth:     220
                selectedId:        root.currentPageId
                navModel:          root.pageIndex

                onPageSelected: function(pageId) {
                    root.currentPageId = pageId
                }
            }

            // ── Content area ──────────────────────────────────
            Item {
                Layout.fillWidth:  true
                Layout.fillHeight: true

                // Title bar
                RowLayout {
                    id: titleBar
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    height: 52
                    leftPadding:  Theme.spacingXl
                    rightPadding: Theme.spacingMd

                    Text {
                        Layout.fillWidth: true
                        text:           activePageMeta ? activePageMeta.label : ""
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeSubtitle
                        font.weight:    Theme.weightSemibold
                        color:          Theme.text
                    }

                    NxIconButton {
                        iconName:   "image://theme/window-close"
                        buttonSize: 34
                        iconSize:   Theme.iconMd
                        onClicked:  root.close()
                        NxTooltip { text: "Close settings" }
                    }
                }

                // Thin divider under title bar
                Rectangle {
                    anchors { top: titleBar.bottom; left: parent.left; right: parent.right }
                    height:  1
                    color:   Theme.border
                    opacity: 0.5
                }

                // Page loader
                Loader {
                    id:      pageLoader
                    anchors {
                        top:    titleBar.bottom
                        left:   parent.left
                        right:  parent.right
                        bottom: parent.bottom
                        topMargin: 1   // below divider
                    }

                    source: activePageMeta ? activePageMeta.source : ""

                    // Fade between pages
                    opacity: status === Loader.Ready ? 1.0 : 0.0
                    Behavior on opacity {
                        enabled: !Theme.reducedMotion
                        NumberAnimation { duration: Theme.durationFast }
                    }
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────
    readonly property var activePageMeta: {
        for (var i = 0; i < pageIndex.length; ++i) {
            if (pageIndex[i].id === currentPageId) return pageIndex[i]
        }
        return null
    }

    Keys.onEscapePressed: root.close()
}
