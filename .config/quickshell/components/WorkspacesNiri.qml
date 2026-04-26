import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    required property ShellScreen screen
    id: root
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: layout.implicitWidth
    radius: 8

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 1
        Repeater {
            id: repeater
            model: Niri.workspaces

            StyledButton {
                id: workspace
                required property var modelData
                required property int index
                visible: index < 11 && modelData.output == screen.name
                implicitWidth: (workspace.textWidth + 25)
                implicitHeight: root.implicitHeight
                radius: Options.buttonRadius
                buttonColor: {
                    if (modelData.isActive && modelData.id == Niri.focusedWindow?.workspaceId) {
                        return containsMouse ? Qt.lighter(Colors.mauve, 1.1) : Colors.mauve
                    } else if (modelData.isActive) {
                        return containsMouse ? Qt.lighter(Colors.peach, 1.1) : Colors.peach
                    } else if (modelData.isUrgent) {
                        return containsMouse ? Colors.red : Colors.base
                    } else {
                        return containsMouse ? Colors.yellow : Colors.base
                    }
                }                    
                buttonText: index
                buttonTextColor: {
                    if (containsMouse || modelData.isActive) {
                        return Colors.base
                    } else if (modelData.isUrgent) {
                        return containsMouse ? Colors.base : Colors.red
                    } else {
                        return Colors.yellow
                    }
                }
                onClick: () => {
                    onClicked: Niri.focusWorkspaceById(modelData.id)
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 100 // Transition duration in milliseconds
                        easing.type: Options.easingTypeIn // Smooth easing curve
                    }
                }
            }
        }
    }
}
