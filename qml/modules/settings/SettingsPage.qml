import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// SettingsPage — base container for every settings page
//
// Each concrete page (AppearancePage, BarPage, …) is placed
// inside Settings.qml as a Loader source.  This base provides:
//   - Consistent vertical padding / max-width
//   - Scrollable content area
//   - Page title + optional subtitle
//   - Helper components: SettingsSection, SettingsRow
// ─────────────────────────────────────────────────────────────
Item {
    id: root

    // ── Page metadata ─────────────────────────────────────────
    property string pageTitle:    ""
    property string pageSubtitle: ""

    // ── Content ───────────────────────────────────────────────
    // Concrete pages place their content here via default property
    default property alias pageContent: contentColumn.data

    implicitWidth:  600
    implicitHeight: parent ? parent.height : 480

    NxScrollView {
        anchors.fill: parent
        contentHeight: outerColumn.implicitHeight + Theme.spacingXxl

        Column {
            id: outerColumn
            width:       Math.min(parent.width, 640)
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding:  Theme.spacingXl
            spacing:     Theme.spacingLg

            // ── Page header ──────────────────────────────────
            Column {
                width:   parent.width
                spacing: Theme.spacingXxs

                Text {
                    text:           root.pageTitle
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeTitle
                    font.weight:    Theme.weightSemibold
                    color:          Theme.text
                    visible:        text !== ""
                }
                Text {
                    text:           root.pageSubtitle
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBody
                    color:          Theme.textSecondary
                    wrapMode:       Text.Wrap
                    width:          parent.width
                    visible:        text !== ""
                }
            }

            // ── Injected content ─────────────────────────────
            Column {
                id:      contentColumn
                width:   parent.width
                spacing: Theme.spacingMd
            }
        }
    }

    // ── Convenience sub-components ────────────────────────────

    // SettingsSection — a labeled group of rows
    component SettingsSection: Column {
        property string label: ""
        width:   parent ? parent.width : 0
        spacing: 0

        // Section label
        Text {
            text:           parent.label
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightSemibold
            color:          Theme.textDisabled
            topPadding:     Theme.spacingMd
            bottomPadding:  Theme.spacingSm
            visible:        text !== ""
        }

        // Section card background
        Rectangle {
            width:  parent.width
            // height driven by children via implicitHeight
            implicitHeight: sectionContent.implicitHeight
            radius: Theme.radiusMd
            color:  Theme.surface
            border.color: Theme.border
            border.width: 1

            Column {
                id: sectionContent
                width:   parent.width
                spacing: 0
                // children injected by caller
            }
        }
    }

    // SettingsRow — a labelled row with trailing control + divider
    component SettingsRow: Item {
        property string rowLabel:    ""
        property string rowSubtitle: ""
        default property alias rowControl: trailingSlot.data

        implicitWidth:  parent ? parent.width : 400
        implicitHeight: Math.max(52, rowContent.implicitHeight + Theme.spacingMd)

        RowLayout {
            id:      rowContent
            anchors {
                left:           parent.left
                right:          parent.right
                verticalCenter: parent.verticalCenter
                leftMargin:     Theme.spacingLg
                rightMargin:    Theme.spacingLg
            }
            spacing: Theme.spacingMd

            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text:           parent.parent.rowLabel
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBody
                    color:          Theme.text
                    visible:        text !== ""
                }
                Text {
                    text:           parent.parent.rowSubtitle
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeCaption
                    color:          Theme.textSecondary
                    visible:        text !== ""
                    wrapMode:       Text.Wrap
                    width:          parent.width
                }
            }

            // Trailing slot — toggle, slider, button, etc.
            Item {
                id:             trailingSlot
                implicitWidth:  childrenRect.width
                implicitHeight: childrenRect.height
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
        }

        // Bottom divider (hidden on last child)
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            anchors.leftMargin:  Theme.spacingLg
            anchors.rightMargin: Theme.spacingLg
            height:  1
            color:   Theme.border
            opacity: 0.5
            visible: parent.parent && (parent.parent.children.length > 1)
                     && (parent !== parent.parent.children[parent.parent.children.length - 1])
        }
    }
}
