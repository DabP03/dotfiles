import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// One application stream: [tile] title / subtitle   [-] 65% [+] [mute]
// Used for single-stream apps (showTile: true) and for the children of a
// group (showTile: false, title = tab/stream name).
Rectangle {
    id: root

    required property PwNode node
    property string title: ""
    property string subtitle: ""
    property bool showTile: true
    property string tileName: title

    readonly property bool containsMouse: hover.hovered
    readonly property bool hasAudio: node !== null && node.audio !== null
    readonly property bool muted: hasAudio ? node.audio.muted : false
    readonly property real volume: hasAudio ? node.audio.volume : 0
    readonly property string iconName: (node && node.properties) ? (node.properties["application.icon-name"] ?? "") : ""

    // Small square button built on StyledButton.
    component SmallButton: StyledButton {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        buttonColor: Colors.surface0
        buttonTextColor: Colors.text
        fontSize: 14
    }

    PwObjectTracker { objects: root.node ? [root.node] : [] }

    implicitHeight: 44
    radius: Options.radius / 2
    color: hover.hovered ? Colors.mantle : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Options.easingTypeOut
        }
    }

    HoverHandler { id: hover }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 10

        AppTile {
            visible: root.showTile
            name: root.tileName
            iconName: root.iconName
            dimmed: root.muted
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0
            clip: true
            opacity: root.muted ? 0.55 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Options.easingTypeOut
                }
            }

            // Stream titles (tweets, tab names) can contain line breaks, so
            // collapse whitespace and force a single elided line.
            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                text: root.title.replace(/\s+/g, " ").trim()
                color: Colors.text
                font.family: Options.font.family
                font.pixelSize: root.showTile ? Options.font.size - 1 : Options.font.size - 2
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                text: root.subtitle.replace(/\s+/g, " ").trim()
                color: Colors.subtext0
                font.family: Options.font.family
                font.pixelSize: 11
            }
        }

        RowLayout {
            spacing: 4

            SmallButton {
                buttonText: "-"
                onClick: () => Audio.decrement(root.node)
            }

            Text {
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignHCenter
                text: Math.round(root.volume * 100) + "%"
                color: root.muted ? Colors.subtext0 : Colors.text
                font.family: Options.font.family
                font.pixelSize: Options.font.size - 1
                font.weight: Font.Medium
                font.strikeout: root.muted
            }

            SmallButton {
                buttonText: "+"
                onClick: () => Audio.increment(root.node)
            }

            SmallButton {
                buttonText: root.muted ? "volume_off" : "volume_up"
                buttonTextColor: root.muted ? Colors.peach : Colors.subtext0
                fontFamily: Options.font.iconFamily
                fontSize: 16
                fill: 1
                onClick: () => Audio.mute(root.node)
            }
        }
    }
}
