import Quickshell.Services.SystemTray
import QtQuick.Layouts
import QtQuick
import "../widgets"

Item {
    id: root

    required property bool barDocked
    readonly property Repeater items: items
    required property var bar

    clip: true
    visible: width > 0 && height > 0 // To avoid warnings about being visible with no size

    implicitWidth: layout.implicitWidth 
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
