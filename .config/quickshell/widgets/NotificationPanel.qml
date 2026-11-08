import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// Notification list for the dash popup. Invisible while there is nothing to
// show; otherwise its implicitHeight is the header plus the list, capped at
// maxListHeight (then the list scrolls).
Rectangle {
    id: root

    property real maxListHeight: 260

    readonly property real maxImplicitHeight: 12 + header.implicitHeight + 8 + maxListHeight + 12

    // visible: NotificationService.hasNotifications
    color: Colors.mantle
    radius: Options.radius

    readonly property real listHeight: NotificationService.hasNotifications
        ? 8 + Math.min(list.contentHeight, maxListHeight)
        : 0

    implicitHeight: 12 + header.implicitHeight + listHeight + 12

    // The dash popup sizes itself from this implicitHeight, so animating it
    // animates the window: clearing notifications shrinks the popup instead of
    // snapping. The popup's top edge stays anchored under the bar, so it grows
    // and shrinks downwards from the bar edge.
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Motion.grow
            easing.type: Motion.inOut
        }
    }

    RowLayout {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 12
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 8

        Icon {
            text: "notifications"
            font.family: Options.font.iconFamily
            font.pixelSize: 18
            color: Colors.lavender
        }

        Text {
            text: "Notifications"
            color: Colors.text
            font.family: Options.font.family
            font.pixelSize: Options.font.size
            font.bold: true
        }

        Rectangle {
            implicitWidth: Math.max(18, countText.implicitWidth + 14)
            implicitHeight: 18
            radius: 9
            color: Colors.base

            Text {
                id: countText
                anchors.centerIn: parent
                text: NotificationService.count
                color: Colors.subtext0
                font.family: Options.font.family
                font.pixelSize: 12
            }
        }

        Item { Layout.fillWidth: true }

        StyledButton {
            Layout.preferredWidth: textWidth + 20
            Layout.preferredHeight: 26
            fontSize: 12
            buttonText: "Clear all"
            buttonColor: Colors.base
            buttonTextColor: Colors.text
            onClick: () => NotificationService.dismissAll()
        }
    }

    ListView {
        id: list
        anchors {
            top: header.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 12
            rightMargin: 12
            bottomMargin: 12
        }
        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 4000 // keep every card instantiated so contentHeight is exact

        model: ScriptModel {
            values: NotificationService.newestFirst
        }

        delegate: NotificationCard {
            required property var modelData
            width: ListView.view.width
            notification: modelData
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Motion.pop; easing.type: Motion.leave }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Motion.grow; easing.type: Motion.inOut }
        }
    }
}
