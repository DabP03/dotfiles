import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle{
    required property ShellScreen screen
    id: root
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: 10 * 30
    radius: 8

    readonly property int offset: screen.name.includes("HDMI") ? 11 : 1
    readonly property int activeIndex: Hyprland.activeWsId - offset
    readonly property bool hasIndicator: activeIndex >= 0 && activeIndex < 10

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // Active workspace marker: one pill that travels along the tile row,
    // like the desktop's workspace slide, instead of a tile repainting.
    Rectangle {
        id: indicator
        visible: root.hasIndicator
        width: 30
        height: root.implicitHeight - 5
        radius: 8
        // The marker brightens on hover of the tile it marks.
        color: reap.itemAt(root.activeIndex)?.hovered ? Qt.lighter(Colors.mauve, 1.1) : Colors.mauve
        anchors.verticalCenter: root.verticalCenter
        x: root.activeIndex * 31

        Behavior on color {
            ColorAnimation {
                duration: Motion.micro
                easing.type: Motion.arrive
            }
        }

        Behavior on x {
            NumberAnimation {
                duration: Motion.slide
                easing.type: Motion.arrive
            }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 1
        Repeater {
            id: reap
            model: 10
            Workspace { 
                required property int index
                indicator: true
                value: index + root.offset
            }
        }
    }
}
