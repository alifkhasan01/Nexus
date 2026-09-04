import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../components"

// ─────────────────────────────────────────────────────────────
// SettingsSidebar — left navigation rail inside Settings
//
// Accepts a ListModel of nav items:
//   { id, label, icon, section }
//
// Emits pageSelected(pageId) when the user taps a row.
// Groups items by the optional `section` field.
// ─────────────────────────────────────────────────────────────
Item {
    id: root

    property int    selectedId: 0
    property var    navModel:   []   // array of { id, label, icon, section }

    signal pageSelected(int pageId)

    implicitWidth:  220
    implicitHeight: parent ? parent.height : 480

    Rectangle {
        anchors.fill: parent
        color:        Theme.surface
        border.color: Theme.border
        border.width: 0

        // Right border only
        Rectangle {
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 1
            color: Theme.border
            opacity: 0.6
        }

        NxScrollView {
            anchors.fill:       parent
            anchors.topMargin:  Theme.spacingMd
            contentHeight:      navColumn.implicitHeight + Theme.spacingXl

            Column {
                id:      navColumn
                width:   parent.width
                spacing: 0

                Repeater {
                    model: root.navModel

                    delegate: Loader {
                        required property var  modelData
                        required property int  index

                        width: navColumn.width

                        // Section header if this item starts a new section
                        sourceComponent: {
                            var showHeader = modelData.section !== undefined
                                && modelData.section !== ""
                                && (index === 0
                                    || root.navModel[index - 1].section !== modelData.section)
                            return showHeader ? sectionHeader : navRow
                        }

                        // Pass data down
                        onLoaded: {
                            if (item.hasOwnProperty("sectionLabel")) {
                                item.sectionLabel = modelData.section
                            } else {
                                item.navId    = modelData.id
                                item.navLabel = modelData.label
                                item.navIcon  = modelData.icon || ""
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Sub-components ────────────────────────────────────────

    component SectionHeader: Item {
        property string sectionLabel: ""
        implicitWidth:  parent ? parent.width : 220
        implicitHeight: 32

        Text {
            anchors {
                left:           parent.left
                verticalCenter: parent.verticalCenter
                leftMargin:     Theme.spacingLg
            }
            text:           sectionLabel
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            font.weight:    Theme.weightSemibold
            color:          Theme.textDisabled
            topPadding:     Theme.spacingSm
        }
    }

    component NavRow: Item {
        property int    navId:    -1
        property string navLabel: ""
        property string navIcon:  ""

        implicitWidth:  parent ? parent.width : 220
        implicitHeight: 40

        readonly property bool isSelected: navId === root.selectedId

        HoverHandler { id: rowHov }

        Rectangle {
            anchors {
                fill:          parent
                leftMargin:    Theme.spacingXs
                rightMargin:   Theme.spacingXs
                topMargin:     2
                bottomMargin:  2
            }
            radius: Theme.radiusMd
            color: isSelected
                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                : (rowHov.hovered ? Theme.surfaceHighlight : "transparent")

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            // Selected accent bar
            Rectangle {
                anchors {
                    left:           parent.left
                    leftMargin:     2
                    verticalCenter: parent.verticalCenter
                }
                width:   3; height: 18
                radius:  2
                color:   Theme.accent
                visible: isSelected
                opacity: 0.9
            }

            RowLayout {
                anchors {
                    fill:          parent
                    leftMargin:    Theme.spacingLg
                    rightMargin:   Theme.spacingMd
                }
                spacing: Theme.spacingMd

                // Icon
                Image {
                    width:   Theme.iconMd; height: Theme.iconMd
                    source:  navIcon !== "" ? "image://theme/" + navIcon : ""
                    fillMode: Image.PreserveAspectFit
                    smooth:  true
                    visible: navIcon !== ""
                    opacity: isSelected ? 1.0 : 0.7
                }

                // Label
                Text {
                    Layout.fillWidth: true
                    text:           navLabel
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.sizeBody
                    font.weight:    isSelected ? Theme.weightSemibold : Theme.weightRegular
                    color:          isSelected ? Theme.text : Theme.textSecondary
                    elide:          Text.ElideRight
                }
            }
        }

        TapHandler {
            onTapped: root.pageSelected(navId)
        }
    }

    // Expose components as properties so they can be used in Loader
    property Component sectionHeader: SectionHeader {}
    property Component navRow:        NavRow {}
}
