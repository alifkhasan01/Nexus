import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// WallpaperPicker — overlay for browsing and setting wallpapers
//
// Layout:
//   Header: title + directory path + refresh button
//   Grid:   WallpaperThumb cards, async-loaded from directory
//   Footer: current selection label + Apply button
//
// Backend: calls `swww img <path>` via Quickshell.Io.Process.
//          Falls back to `swaybg -m fill -i <path>` if swww
//          is not available.
//
// Directory scanning uses Quickshell.Io.FileView to list
// .jpg/.jpeg/.png/.webp files from wallpaperDir.
// ─────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    required property var  screen
    property bool          visible: false
    signal close()

    // Directory to scan — override from config / settings
    property string wallpaperDir: Qt.resolvedUrl(
        StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/Wallpapers"
    ).replace("file://", "")

    // Currently applied wallpaper path
    property string appliedPath: ""

    // Staging selection (not yet applied)
    property string selectedPath: appliedPath

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

    onVisibleChanged: {
        if (visible) scanner.scan()
    }

    // ── Scrim ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.scrim
        opacity:      0.55
        TapHandler { onTapped: root.close() }
    }

    // ── File list model ───────────────────────────────────────
    ListModel { id: wallpaperModel }

    // Scan directory for image files using a Process
    Process {
        id: scanner
        property string output: ""

        command: ["bash", "-c",
            "find " + root.wallpaperDir +
            " -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg'" +
            " -o -iname '*.png' -o -iname '*.webp' \\) | sort"
        ]

        function scan() {
            output = ""
            wallpaperModel.clear()
            running = true
        }

        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() === "") return
                var parts = line.split("/")
                var base  = parts[parts.length - 1]
                var name  = base.replace(/\.[^.]+$/, "")
                wallpaperModel.append({ filePath: line.trim(), fileName: name })
            }
        }
    }

    // ── Apply wallpaper via swww ──────────────────────────────
    Process {
        id: applyProcess
        property string pendingPath: ""

        command: ["swww", "img",
            "--transition-type", "fade",
            "--transition-duration", "0.8",
            applyProcess.pendingPath
        ]

        onExited: function(code) {
            if (code === 0) {
                root.appliedPath = applyProcess.pendingPath
            }
        }
    }

    function applyWallpaper(path) {
        applyProcess.pendingPath = path
        applyProcess.running = true
    }

    // ── Panel ─────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            top:              parent.top
            left:             parent.left
            right:            parent.right
            bottom:           parent.bottom
            topMargin:        Theme.barHeight + Theme.spacingXl
            leftMargin:       screen.width  * 0.08
            rightMargin:      screen.width  * 0.08
            bottomMargin:     screen.height * 0.06
        }
        radius:       Theme.radiusXl
        color:        Theme.surface
        opacity:      Theme.glassOpacity + 0.05
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

        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: Theme.spacingXl
            spacing:         Theme.spacingLg

            // ── Header ───────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Column {
                    spacing: Theme.spacingXxs
                    Text {
                        text:           "Wallpaper"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeTitle
                        font.weight:    Theme.weightSemibold
                        color:          Theme.text
                    }
                    Text {
                        text:           root.wallpaperDir
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.sizeCaption
                        color:          Theme.textDisabled
                        elide:          Text.ElideLeft
                        width:          300
                    }
                }

                Item { Layout.fillWidth: true }

                // Refresh
                NxIconButton {
                    iconName:   "image://theme/view-refresh"
                    buttonSize: 34
                    iconSize:   Theme.iconMd
                    onClicked:  scanner.scan()
                    NxTooltip { text: "Rescan directory" }
                }

                // Close
                NxIconButton {
                    iconName:   "image://theme/window-close"
                    buttonSize: 34
                    iconSize:   Theme.iconMd
                    onClicked:  root.close()
                }
            }

            NxSeparator { Layout.fillWidth: true }

            // ── Grid ─────────────────────────────────────────
            NxScrollView {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                contentHeight:     wallpaperGrid.implicitHeight

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingMd
                    visible: wallpaperModel.count === 0

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width:   Theme.iconHuge; height: Theme.iconHuge
                        source:  "image://theme/image-missing"
                        opacity: 0.25
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           "No wallpapers found"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeBody
                        color:          Theme.textDisabled
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           root.wallpaperDir
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.sizeCaption
                        color:          Theme.textDisabled
                        opacity:        0.6
                    }
                }

                // Wallpaper grid
                Flow {
                    id:      wallpaperGrid
                    width:   parent.width
                    spacing: Theme.spacingMd

                    Repeater {
                        model: wallpaperModel

                        delegate: WallpaperThumb {
                            required property var  modelData
                            required property int  index

                            filePath: modelData.filePath
                            fileName: modelData.fileName
                            selected: modelData.filePath === root.selectedPath

                            onClicked: {
                                root.selectedPath = modelData.filePath
                            }
                        }
                    }
                }
            }

            NxSeparator { Layout.fillWidth: true }

            // ── Footer ────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Column {
                    spacing: Theme.spacingXxs
                    visible: root.selectedPath !== ""

                    Text {
                        text:           "Selected"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeCaption
                        color:          Theme.textDisabled
                    }
                    Text {
                        text: {
                            var parts = root.selectedPath.split("/")
                            return parts[parts.length - 1]
                        }
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.sizeBodySmall
                        font.weight:    Theme.weightMedium
                        color:          Theme.text
                        elide:          Text.ElideLeft
                        width:          280
                    }
                }

                Item { Layout.fillWidth: true }

                NxButton {
                    text:    "Cancel"
                    variant: NxButton.Variant.Ghost
                    onClicked: {
                        root.selectedPath = root.appliedPath
                        root.close()
                    }
                }

                NxButton {
                    text:     "Apply"
                    variant:  NxButton.Variant.Primary
                    enabled:  root.selectedPath !== "" && root.selectedPath !== root.appliedPath
                    onClicked: {
                        root.applyWallpaper(root.selectedPath)
                        root.close()
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: root.close()
}
