import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

ColumnLayout {
    id: root
    required property string appName
    required property var nodes // array<PwNode>, all streams belonging to appName
    spacing: 4

    // The indentation (left margin + tree connector) eats into the row width,
    // so child sliders are scaled down a bit to keep every row's total width
    // consistent with top-level entries. Tune this if it still looks off.
    property real childSliderScale: 0.96

    readonly property bool isGroup: nodes.length > 1

    // Aggregated hover state so the parent popup can decide whether to stay open.
    property bool containsMouse: {
        if (!root.isGroup) return singleEntry.containsMouse
        for (let i = 0; i < childRepeater.count; i++) {
            const item = childRepeater.itemAt(i)
            if (item && item.entry && item.entry.containsMouse) return true
        }
        return false
    }

    // Single stream for this app: just show it directly, no tree needed.
    MixerEntry {
        id: singleEntry
        Layout.leftMargin: 24
        visible: !root.isGroup
        Layout.alignment: Qt.AlignHCenter
        node: root.nodes[0]
        name: root.appName
    }

    // Multiple streams for this app (e.g. several browser tabs): app header + tree.
    ColumnLayout {
        visible: root.isGroup
        Layout.alignment: Qt.AlignHCenter
        spacing: 4

            Text {
            Layout.leftMargin: 14
                text: root.appName
                color: Colors.text
                font.bold: true
                font.pixelSize: Options.font.size - 2
                font.family: Options.font.family
            }

        Repeater {
            id: childRepeater
            model: root.nodes

            RowLayout {
                id: childRow
                required property PwNode modelData
                property alias entry: childEntry
                Layout.leftMargin: 24
                spacing: 6

                Rectangle {
                    implicitWidth: 2
                    Layout.fillHeight: true
                    color: Colors.surface0
                }

                MixerEntry {
                    id: childEntry
                    node: childRow.modelData
                    sliderScale: root.childSliderScale
                    // Prefer the per-stream title (e.g. tab name) over the app name.
                    name: childRow.modelData.properties["media.name"]
                        ?? childRow.modelData.properties["media.title"]
                        ?? childRow.modelData.nickname
                        ?? childRow.modelData.name
                        ?? "Stream"
                }
            }
        }
    }
}
