pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/config"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property bool barDocked
    required property SystemTrayItem item
    required property var bar

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 11 * 2
    implicitHeight: 11 * 2

    onClicked: event => {
        if (event.button === Qt.LeftButton)
        item.activate();
        else if (item.hasMenu)
        menu.open();
    }

    QsMenuAnchor {
        id: menu

        menu: root.item.menu
        anchor.window: bar
        anchor.rect.x: root.x + (
            bar.width
            - Options.width.battery
            - Options.width.audio
            - Options.width.network
            - Options.width.dash
            - (30 * SystemTray.items.values.length)
        )
        - (Options.margin.inner * 4)
        - Options.margin.inner * root.barDocked
        - 64 // WTF
        anchor.rect.y: icon.y + bar.height - 32
        anchor.rect.height: root.height
        anchor.edges: Edges.Bottom
    }

    IconImage {
        id: icon

        source: {
            let icon = root.item.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
            }
            return icon;
        }
        asynchronous: true
        anchors.fill: parent
    }
}
