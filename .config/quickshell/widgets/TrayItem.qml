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
        anchor.item: root
        anchor.rect.x: 0
        anchor.rect.y: bar.height - 3 - root.mapToItem(null, 0, 0).y
        anchor.rect.width: root.width
        anchor.rect.height: 0
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.None
        menu: root.item.menu
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
