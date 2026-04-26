import "root:/config"
import "root:/widgets"
import Quickshell.Services.SystemTray
import QtQuick.Layouts
import QtQuick

Item {
    id: root

    required property bool barDocked
    readonly property Repeater items: items
    required property var bar

    clip: true
    visible: width > 0 && height > 0 // To avoid warnings about being visible with no size

    implicitWidth: {
        let width = layout.implicitWidth 
        Options.width.tray = width;
        return width;
    }

    implicitHeight: parent.implicitHeight - 12

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 8

        Repeater {
            id: items

            model: SystemTray.items

            TrayItem {
                required property SystemTrayItem modelData
                barDocked: root.barDocked
                item: modelData
                bar: root.bar
            }
        }
    }
}
