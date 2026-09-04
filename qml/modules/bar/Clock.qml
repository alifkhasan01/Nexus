import QtQuick
import "../../theme"

// Clock — live time display (HH:MM) with date tooltip
Item {
    id: root

    implicitWidth:  timeText.implicitWidth + Theme.spacingMd
    implicitHeight: Theme.barHeight

    // Update every 10 seconds — precise enough, avoids unnecessary redraws
    Timer {
        id: clockTimer
        interval:  10000
        repeat:    true
        running:   true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            timeText.text = now.toLocaleTimeString(Qt.locale(), "HH:mm")
            dateText.text = now.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            font.family:  Theme.fontFamily
            font.pixelSize: Theme.sizeBody
            font.weight:  Theme.weightSemibold
            color:        Theme.text
        }
    }

    // Hover reveals full date
    HoverHandler { id: hov }

    // Date tooltip on hover
    Rectangle {
        anchors {
            top:              parent.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin:        Theme.spacingXs
        }
        width:   dateText.implicitWidth + Theme.spacingMd
        height:  dateText.implicitHeight + Theme.spacingSm
        radius:  Theme.radiusSm
        color:   Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1
        visible: hov.hovered

        Text {
            id: dateText
            anchors.centerIn: parent
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.sizeCaption
            color:          Theme.textSecondary
        }
    }
}
