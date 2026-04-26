import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"

Rectangle {
    id: root
    required property int value

    Behavior on color {
        ColorAnimation {
            duration: 200 // Transition duration in milliseconds
            easing.type: Options.easingTypeOut
        }
    }
    color: {
        if (Hyprland.activeWsId === value) {
            return mouseArea.containsMouse ? Qt.lighter(Colors.mauve, 1.1) : Colors.mauve
        } else if (Hyprland.filledWsIds.includes(value)) {
            if (Hyprland.workspacesWindows.includes(value)) {
                return mouseArea.containsMouse ? Qt.lighter(Colors.peach, 1.1) : Colors.peach
            }
            return mouseArea.containsMouse ? Colors.peach : Colors.base
        } else {
            return mouseArea.containsMouse ? Colors.yellow : Colors.base
        }
    }
    implicitHeight: parent.height - 5
    implicitWidth: 30
    radius: 8

    Text {
        id: workspaceText
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation {
                duration: 200 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut
            }
        }

        color: {
            if (mouseArea.containsMouse) {
                return Colors.base
            } else if (Hyprland.activeWsId === value) {
                return Colors.base
            } else if (Hyprland.filledWsIds.includes(value)) {
                if (Hyprland.workspacesWindows.includes(value)) {
                    return Colors.base
                } else {
                    return Colors.peach
                }
            } else {
                return Colors.yellow
            }
        }
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

        function handleClicked(event) {
            Hyprland.dispatch("workspace " + value)
        }

        function handleWheel(event) {
            event.accepted = true // Prevent default scroll behavior
            if (event.angleDelta.y > 0) {
                Hyprland.dispatch("workspace +1")
            } else {
                Hyprland.dispatch("workspace -1")
            }

        }

        // Bind signal handlers to functions
        onClicked: (event) => handleClicked(event)
        onWheel: (event) => handleWheel(event)
    }
}
