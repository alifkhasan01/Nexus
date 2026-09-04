import QtQuick
import Nexus.Services 1.0
import "../../theme"
import "../../components"

// LauncherResult — scrollable list of search results
Item {
    id: root

    property string searchText: ""
    property int    maxHeight:  400

    signal appLaunched()

    implicitHeight: Math.min(listView.contentHeight + Theme.spacingSm * 2, maxHeight)

    property var results: []
    property int selectedIndex: 0

    function refresh(query) {
        results = AppIndexer.search(query, 10)
        selectedIndex = 0
    }

    function moveSelection(delta) {
        if (results.length === 0) return
        selectedIndex = (selectedIndex + delta + results.length) % results.length
        listView.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function launchSelected() {
        if (results.length === 0) return
        var app = results[selectedIndex]
        AppIndexer.launch(app.id)
        root.appLaunched()
    }

    // Section header when query is empty: "Recent"
    Text {
        anchors {
            top:      parent.top
            left:     parent.left
            leftMargin: Theme.spacingLg
        }
        text:           root.searchText.length === 0 ? "Recents" : ""
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.sizeCaption
        font.weight:    Theme.weightSemibold
        color:          Theme.textDisabled
        topPadding:     Theme.spacingSm
        visible:        root.searchText.length === 0
    }

    ListView {
        id: listView
        anchors {
            top:          parent.top
            left:         parent.left
            right:        parent.right
            topMargin:    root.searchText.length === 0 ? Theme.spacingLg : Theme.spacingSm
        }
        height:       root.maxHeight - anchors.topMargin
        clip:         true
        model:        root.results
        spacing:      2
        currentIndex: root.selectedIndex

        delegate: LauncherResultItem {
            required property var  modelData
            required property int  index

            width:    listView.width
            appName:  modelData.name
            appIcon:  modelData.iconPath !== "" ? modelData.iconPath : "image://theme/" + modelData.icon
            appId:    modelData.id
            selected: index === root.selectedIndex

            onClicked: {
                root.selectedIndex = index
                root.launchSelected()
            }
            onHovered: {
                root.selectedIndex = index
            }
        }
    }

    // Empty state
    Item {
        anchors.centerIn: parent
        visible: root.results.length === 0 && root.searchText.length > 0

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingSm

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconXl; height: Theme.iconXl
                source: "image://theme/system-search"
                opacity: 0.25
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No results for \"" + root.searchText + "\""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.sizeBody
                color:          Theme.textDisabled
            }
        }
    }
}
