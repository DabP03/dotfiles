import QtQuick
import Quickshell
import Quickshell.Widgets

import "root:/config/"

// 28px rounded tile. Shows the app's icon when the theme has it, otherwise a
// colored tile with the app's first letter (color picked from the name, so it
// stays stable per app).
Rectangle {
    id: root

    property string name: ""
    property string iconName: ""   // e.g. node.properties["application.icon-name"]
    property bool dimmed: false

    readonly property string iconSource: iconName !== "" ? Quickshell.iconPath(iconName, true) : ""
    readonly property var palette: [Colors.peach, Colors.teal, Colors.lavender, Colors.blue]

    function colorFor(s) {
        let h = 0;
        for (let i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) | 0;
        return palette[Math.abs(h) % palette.length];
    }

    implicitWidth: 28
    implicitHeight: 28
    radius: Options.radius / 2
    color: iconSource !== "" ? Colors.surface0 : colorFor(name)
    opacity: dimmed ? 0.45 : 1

    Behavior on opacity {
        NumberAnimation {
            duration: 120
            easing.type: Options.easingTypeOut
        }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 20
        source: root.iconSource
        visible: root.iconSource !== ""
        asynchronous: true
    }

    Text {
        anchors.centerIn: parent
        visible: root.iconSource === ""
        text: root.name.charAt(0).toUpperCase()
        color: Colors.base
        font.bold: true
        font.family: Options.font.family
        font.pixelSize: Options.font.size
    }
}
