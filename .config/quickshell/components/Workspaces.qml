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
            id: reap
            model: 10
            Workspace { 
                required property int index
                value: {
                    let screenName = root.screen.name
                    if (screenName.includes("DP")) return index + 1 // Example for HDMI monitor
                    else if (screenName.includes("HDMI")) return index + 11
                }
            }
        }
    }
}
