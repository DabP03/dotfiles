import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// Popup contents for the media player: cover art, track info, seek bar,
// transport controls and the source chip. Everything reads Players.active
// through `player` and tolerates it being null.
Rectangle {
    id: root

    readonly property var player: Players.active
    readonly property bool hasPlayer: player !== null && player !== undefined
    readonly property real contentWidth: width - 28
    property real artSize: contentWidth
    property color accent: Colors.yellow

    color: Colors.base
    radius: Options.radius
    topLeftRadius: 0
    topRightRadius: 0
    border.color: Colors.peach
    border.width: Options.borderWidth

    implicitWidth: 340
    implicitHeight: hasPlayer ? content.implicitHeight + 28 : 140

    // Square icon button on StyledButton, drawn with the icon font.
    component ControlButton: StyledButton {
        Layout.preferredWidth: 38
        Layout.preferredHeight: 38
        buttonColor: Colors.surface0
        buttonTextColor: Colors.text
        fontFamily: Options.font.iconFamily
        fontSize: 20
        fill: 1
    }

    // Hides the popup's top border so it joins the bar (same trick as before).
    Rectangle {
        width: parent.width - Options.borderWidth * 2
        height: Options.borderWidth
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: Colors.base
    }

    // ── nothing playing ──
    Text {
        anchors.centerIn: parent
        visible: !root.hasPlayer
        text: "Nothing playing"
        color: Colors.subtext0
        font.family: Options.font.family
        font.pixelSize: Options.font.size
    }

    ColumnLayout {
        id: content
        visible: root.hasPlayer
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 14
        }
        spacing: 0

        // ── cover art ──
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: root.artSize
            implicitHeight: root.artSize
            radius: Options.radius
            color: Colors.surface0

            RoundedImage {
                anchors.fill: parent
                imgSource: root.player ? root.player.trackArtUrl : ""
                radius: Options.radius
            }
        }

        // ── track info ──
        ColumnLayout {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 2

            ScrollingText {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Math.min(textWidth, root.contentWidth)
                color: Colors.text
                font.pixelSize: Options.font.size + 2
                font.family: Options.font.family
                font.bold: true
                dwellTime: 4000
                text: root.player ? root.player.trackTitle : ""
            }

            ScrollingText {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Math.min(textWidth, root.contentWidth)
                color: root.accent
                font.pixelSize: Options.font.size
                font.family: Options.font.family
                font.bold: true
                dwellTime: 4000
                text: root.player ? root.player.trackArtist : ""
            }

            ScrollingText {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Math.min(textWidth, root.contentWidth)
                color: Colors.subtext0
                font.pixelSize: Options.font.size - 1
                font.family: Options.font.family
                dwellTime: 4000
                text: root.player ? root.player.trackAlbum : ""
            }
        }

        // ── progress ──
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 10

            Text {
                text: root.player ? Players.formatTime(root.player.position) : "0:00"
                color: Colors.subtext0
                font.pixelSize: Options.font.size - 2
                font.family: Options.font.family
            }

            Slider {
                id: durationSlider
                Layout.fillWidth: true
                implicitHeight: 22
                from: 0
                to: (root.player && root.player.length > 0) ? root.player.length : 1
                enabled: root.player ? root.player.canSeek : false

                // Imperative updates (not a binding) so dragging doesn't fight
                // with position ticks arriving mid-seek.
                Component.onCompleted: value = root.player ? root.player.position : 0

                Connections {
                    target: root.player

                    function onPositionChanged() {
                        if (!durationSlider.pressed)
                            durationSlider.value = root.player.position
                    }

                    function onTrackChanged() {
                        durationSlider.value = root.player.position
                    }
                }

                Connections {
                    target: root

                    function onPlayerChanged() {
                        durationSlider.value = root.player ? root.player.position : 0
                    }
                }

                onMoved: () => {
                    if (root.player)
                        root.player.position = durationSlider.value
                }

                background: Rectangle {
                    x: durationSlider.leftPadding
                    y: durationSlider.topPadding + durationSlider.availableHeight / 2 - height / 2
                    width: durationSlider.availableWidth
                    height: 6
                    radius: 3
                    color: Colors.surface0

                    Rectangle {
                        width: durationSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: root.accent
                    }
                }

                handle: Rectangle {
                    x: durationSlider.leftPadding + durationSlider.visualPosition * (durationSlider.availableWidth - width)
                    y: durationSlider.topPadding + durationSlider.availableHeight / 2 - height / 2
                    implicitWidth: 14
                    implicitHeight: 14
                    radius: 7
                    color: durationSlider.pressed ? root.accent : Colors.text
                }
            }

            Text {
                text: root.player ? Players.formatTime(root.player.length) : "0:00"
                color: Colors.subtext0
                font.pixelSize: Options.font.size - 2
                font.family: Options.font.family
            }
        }

        // ── transport controls ──
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            spacing: 8

            ControlButton {
                readonly property bool on: root.player ? root.player.shuffle : false
                buttonText: "shuffle"
                buttonColor: on ? Qt.alpha(root.accent, 0.2) : Colors.surface0
                buttonTextColor: on ? root.accent : Colors.text
                opacity: (root.player && root.player.shuffleSupported) ? 1 : 0.4
                onClick: () => Players.shuffle()
            }

            ControlButton {
                buttonText: "skip_previous"
                opacity: (root.player && root.player.canGoPrevious) ? 1 : 0.4
                onClick: () => Players.previous()
            }

            ControlButton {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                fontSize: 26
                buttonText: (root.player && root.player.playbackState === MprisPlaybackState.Playing) ? "pause" : "play_arrow"
                buttonColor: root.accent
                buttonTextColor: Colors.base
                opacity: (root.player && root.player.canTogglePlaying) ? 1 : 0.4
                onClick: () => Players.playPause()
            }

            ControlButton {
                buttonText: "skip_next"
                opacity: (root.player && root.player.canGoNext) ? 1 : 0.4
                onClick: () => Players.next()
            }

            ControlButton {
                readonly property bool on: root.player ? root.player.loopState !== MprisLoopState.None : false
                buttonText: (root.player && root.player.loopState === MprisLoopState.Track) ? "repeat_one" : "repeat"
                buttonColor: on ? Qt.alpha(root.accent, 0.2) : Colors.surface0
                buttonTextColor: on ? root.accent : Colors.text
                opacity: (root.player && root.player.loopSupported) ? 1 : 0.4
                onClick: () => Players.loop()
            }
        }

        // ── source chip ──
        Rectangle {
            id: chip
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            readonly property string identity: root.player ? root.player.identity : ""
            readonly property string iconName: Players.getSourceIcon(identity)

            implicitHeight: 30
            implicitWidth: chipRow.implicitWidth + 16
            radius: height / 2
            color: Colors.surface0

            RowLayout {
                id: chipRow
                anchors.centerIn: parent
                spacing: 6

                Image {
                    visible: chip.iconName !== ""
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    sourceSize: Qt.size(22, 22)
                    fillMode: Image.PreserveAspectFit
                    source: chip.iconName !== "" ? Quickshell.iconPath(chip.iconName) : ""
                }

                Text {
                    text: Players.getSourceName(chip.identity)
                    color: Colors.text
                    font.bold: true
                    font.pixelSize: Options.font.size - 2
                    font.family: Options.font.family
                }
            }
        }
    }
}
