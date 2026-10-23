import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// "Applications" section of the audio popup: heading + scrolling list of
// MixerGroup, one per app in Audio.groupedSinks.
//
// Collapse state lives here (keyed by app name) so groups keep their state
// when Audio.groupedSinks is rebuilt after a stream appears or disappears.
Item {
    id: root

    property var collapsed: ({})
    property bool animateGroups: true

    // Normalized copy of Audio.groupedSinks. `key` is the stable identity used by
    // the ScriptModel below, so a rebuilt array doesn't recreate the delegates.
    readonly property var groups: {
        const out = [];
        for (const g of Audio.groupedSinks) {
            if (!g.nodes || g.nodes.length === 0)
                continue;
            out.push({
                key: g.appName || ("node-" + g.nodes[0].id),
                appName: g.appName || "Unknown",
                nodes: g.nodes
            });
        }
        return out;
    }

    readonly property int streamCount: {
        let c = 0;
        for (const g of groups)
            c += g.nodes.length;
        return c;
    }

    function groupByKey(key) {
        for (const g of groups) {
            if (g.key === key)
                return g;
        }
        return null;
    }

    // Height this section wants when nothing needs scrolling.
    readonly property real wantedHeight: header.implicitHeight + 8 + list.contentHeight

    function toggleGroup(name) {
        const c = Object.assign({}, collapsed);
        c[name] = !c[name];
        collapsed = c;
    }

    RowLayout {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: 2
            rightMargin: 2
        }

        Text {
            Layout.fillWidth: true
            text: "Applications"
            color: Colors.subtext0
            font.family: Options.font.family
            font.pixelSize: Options.font.size - 1
            font.bold: true
        }

        Text {
            text: root.streamCount + (root.streamCount === 1 ? " stream" : " streams")
            color: Colors.subtext0
            font.family: Options.font.family
            font.pixelSize: 12
        }
    }

    ListView {
        id: list
        anchors {
            top: header.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 4000 // keep every group instantiated so contentHeight is exact
        model: ScriptModel {
            values: root.groups
            objectProp: "key"
        }

        delegate: MixerGroup {
            required property var modelData
            // Always read the live entry: the model keeps the delegate when the key
            // matches, but its modelData may be the older object.
            readonly property var live: root.groupByKey(modelData.key)

            width: ListView.view.width
            appName: live ? live.appName : modelData.appName
            nodes: live ? live.nodes : modelData.nodes
            animated: root.animateGroups
            expanded: !root.collapsed[modelData.key]
            onToggleRequested: root.toggleGroup(modelData.key)
        }
    }
}
