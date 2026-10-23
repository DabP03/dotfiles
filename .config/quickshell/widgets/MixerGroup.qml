import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// One application in the mixer.
//   - one stream  -> a plain AppStreamRow
//   - >1 streams  -> a header (chevron, tile, name, count, mute-all) that
//                    collapses an indented list of AppStreamRows
//
// Collapse state is owned by the parent (see AppMixerList) so it survives
// the model being rebuilt: bind `expanded`, and handle `toggleRequested`.
ColumnLayout {
    id: root

    required property string appName
    required property var nodes // array<PwNode>, all streams belonging to appName

    property bool expanded: true
    property bool animated: true
    signal toggleRequested()

    readonly property bool isGroup: nodes.length > 1
    readonly property bool containsMouse: hover.hovered

    readonly property bool allMuted: {
        if (nodes.length === 0)
            return false;
        for (const n of nodes) {
            if (!(n.audio && n.audio.muted))
                return false;
        }
        return true;
    }

    readonly property string iconName: (nodes.length > 0 && nodes[0].properties)
        ? (nodes[0].properties["application.icon-name"] ?? "") : ""

    function streamTitle(n) {
        const p = (n && n.properties) ? n.properties : ({});
        return p["media.name"] || p["media.title"] || (n ? (n.nickname || n.name) : "") || "Stream";
    }

    // Mute everything in the group, or unmute if everything is already muted.
    function toggleMuteAll() {
        const target = !allMuted;
        for (const n of nodes) {
            if (n.audio)
                n.audio.muted = target;
        }
    }

    component SmallButton: StyledButton {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        buttonColor: Colors.surface0
        buttonTextColor: Colors.text
        fontSize: 14
    }

    spacing: 0

    HoverHandler { id: hover }
    PwObjectTracker { objects: root.nodes }

    // ── single stream: no tree needed ──
    AppStreamRow {
        visible: !root.isGroup
        Layout.fillWidth: true
        node: root.nodes.length > 0 ? root.nodes[0] : null
        title: root.appName
        subtitle: {
            if (root.isGroup || root.nodes.length === 0)
                return "";
            const t = root.streamTitle(root.nodes[0]);
            return (t !== root.appName && t !== "Stream") ? t : "";
        }
    }

    // ── group header ──
    Rectangle {
        id: header
        visible: root.isGroup
        Layout.fillWidth: true
        implicitHeight: 44
        radius: Options.radius / 2
        color: headerHover.hovered ? Colors.mantle : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Options.easingTypeOut
            }
        }

        HoverHandler { id: headerHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleRequested()
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 6
                rightMargin: 10
            }
            spacing: 10

            Icon {
                text: "chevron_right"
                font.family: Options.font.iconFamily
                font.pixelSize: 18
                color: Colors.subtext0
                rotation: root.expanded ? 90 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 150
                        easing.type: Options.easingTypeOut
                    }
                }
            }

            AppTile {
                name: root.appName
                iconName: root.iconName
                dimmed: root.allMuted
            }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: root.appName
                color: Colors.text
                opacity: root.allMuted ? 0.55 : 1
                font.family: Options.font.family
                font.pixelSize: Options.font.size
                font.weight: Font.Medium
            }

            Rectangle {
                implicitWidth: Math.max(18, countText.implicitWidth + 14)
                implicitHeight: 18
                radius: 9
                color: Colors.surface0

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: root.nodes.length
                    color: Colors.subtext0
                    font.family: Options.font.family
                    font.pixelSize: 12
                }
            }

            SmallButton {
                buttonText: root.allMuted ? "volume_off" : "volume_up"
                buttonTextColor: root.allMuted ? Colors.peach : Colors.subtext0
                fontFamily: Options.font.iconFamily
                fontSize: 16
                fill: 1
                onClick: () => root.toggleMuteAll()
            }
        }
    }

    // ── collapsible body ──
    Item {
        visible: root.isGroup
        enabled: root.expanded
        Layout.fillWidth: true
        implicitHeight: root.expanded ? body.implicitHeight : 0
        opacity: root.expanded ? 1 : 0
        clip: true

        Behavior on implicitHeight {
            enabled: root.animated
            NumberAnimation {
                duration: 160
                easing.type: Options.easingTypeOut
            }
        }

        Behavior on opacity {
            enabled: root.animated
            NumberAnimation {
                duration: 120
                easing.type: Options.easingTypeOut
            }
        }

        // tree guide line
        Rectangle {
            x: 24
            y: 2
            width: 2
            height: Math.max(0, body.implicitHeight - 4)
            radius: 1
            color: Colors.surface0
        }

        ColumnLayout {
            id: body
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: 30
            }
            spacing: 2

            Repeater {
                // ScriptModel keeps child rows alive when the nodes array is rebuilt.
                model: ScriptModel { values: root.nodes }

                AppStreamRow {
                    required property var modelData
                    Layout.fillWidth: true
                    node: modelData
                    showTile: false
                    title: root.streamTitle(modelData)
                }
            }
        }
    }
}
