import QtQuick

import "../config/"
import "../services/"

Rectangle {
    id: root
    required property int value
    // Set to true when a parent draws the travelling active marker; otherwise
    // this tile paints itself so the active workspace stays visible.
    property bool indicator: false

    readonly property bool active: Hyprland.activeWsId === value
    readonly property bool filled: Hyprland.filledWsIds.includes(value)
    readonly property bool hovered: mouseArea.containsMouse

    implicitHeight: parent.height - 5
    implicitWidth: 30
    radius: 8

    color: {
        if (!hovered)
            return active && !indicator ? Colors.mauve : "transparent";
        // When a parent marker marks the active tile, brighten the marker instead
        // of painting the tile over it - painting here makes the marker blink.
        if (active && indicator)
            return "transparent";
        return filled ? Colors.peach : Colors.yellow;
    }

    Behavior on color {
        ColorAnimation {
            duration: Motion.micro
            easing.type: Motion.arrive
        }
    }

    Text {
        id: workspaceText
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation {
                duration: Motion.micro
                easing.type: Motion.arrive
            }
        }

        // Colour is paired with position (the pill) so state survives without it.
        color: mouseArea.containsMouse || active ? Colors.base : filled ? Colors.peach : Colors.yellow
        font.bold: true
        font.family: Options.font.family
        font.pixelSize: Options.font.size
        text: value
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true // Needed for scroll wheel detection

        onClicked: {
            Hyprland.dispatch(`hl.dsp.focus({ workspace = "${value}" })`)
        }

        onWheel: (event) => {
            event.accepted = true // Prevent default scroll behavior
            if (event.angleDelta.y > 0) {
                Hyprland.dispatch(`hl.dsp.focus({ workspace = "+1" })`)
            } else {
                Hyprland.dispatch(`hl.dsp.focus({ workspace = "-1" })`)
            }

        }
    }
}
