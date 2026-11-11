import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

import "../config/"
import "../services/"
import "../widgets/"

Rectangle {
    id: root
    color: "transparent"
    required property var bar
    required property bool barDocked
    implicitHeight: parent.implicitHeight - 16
    implicitWidth:(songInfo.implicitWidth + 28 + 8 + 20) * (Players.active != null)
    radius: 8

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.grow
            easing.type: Motion.arrive
        }
    }

    MouseArea {
        id: mouseArea
        implicitHeight: parent.implicitHeight
        implicitWidth: parent.implicitWidth
        anchors.centerIn: parent
        hoverEnabled: true
        onWheel: (event) => {
            event.accepted = true // Prevent default scroll behavior
            volumeIndicator.opacity = 1
            let increment = event.angleDelta.y > 0 ? 0.05 : -0.05
            Players.changeVolume(increment)
            hideTimer.running ? hideTimer.restart() : hideTimer.start()
        }
        onClicked: popup.toggle()
    }

    Rectangle {
        id: colorRect
        implicitHeight: parent.implicitHeight
        implicitWidth: parent.implicitWidth
        anchors.centerIn: parent
        radius: 8
        color: mouseArea.containsMouse ? Qt.lighter(Colors.yellow, 1.1) : Colors.yellow

        Behavior on color {
            ColorAnimation {
                duration: Motion.micro
                easing.type: Motion.arrive
            }
        }

        Timer {
            id: hideTimer
            interval: 500
            repeat: false
            onTriggered: {
                volumeIndicator.opacity = 0
            }
        }

        Rectangle {
            id: volumeIndicator
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: parent.implicitWidth + 4  * (Players.active != null)
            implicitHeight: parent.implicitHeight * (1 - Players.volume)
            color: Colors.base
            opacity: 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Motion.fade
                    easing.type: Motion.inOut
                }
            }
            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Motion.pop
                    easing.type: Motion.arrive
                }
            }
        }


        RoundedImage {
            id: songImg
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 8
            }
            height: 28
            width: 28  * (Players.active != null)
            imgSource: Players.active?.trackArtUrl ?? ""
            // Bar art is always 28 px; don't decode high-res cover art.
            decodeWidth: 28
            decodeHeight: 28
            radius: Options.radius
        }

        Text {
            id: playPauseIcon
            property bool playPauseVisible: false
            anchors {
                verticalCenter: songImg.verticalCenter
                horizontalCenter: songImg.horizontalCenter
            }
            text: Players.active?.canPlay && Players.active?.canPause && Players.active?.canControl
                ? (Players.active.playbackState === MprisPlaybackState.Playing ? "" : "")
                : ""
            color: Colors.yellow
            style: Text.Outline; styleColor: Colors.base
            font.pixelSize: Options.font.size + 4
            font.family: Options.font.family
            font.bold: true
            opacity: (playPauseVisible && Players.active != null) ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Motion.fade
                    easing.type: Motion.inOut
                }
            }

            Timer {
                id: playPauseTimer
                interval: 500
                running: false
                repeat: false
                onTriggered: {
                    if (Players.active?.playbackState == MprisPlaybackState.Playing)
                    playPauseIcon.playPauseVisible = false
                }
            }

            onTextChanged: {
                playPauseVisible = true   // set the property, not opacity directly
                playPauseTimer.restart()
            }

        }


        ScrollingText {
            id: songInfo
            implicitWidth: textWidth < 320 ? textWidth : 320
            anchors {
                verticalCenter: parent.verticalCenter
                left: songImg.right
                leftMargin: 8
            }

            color: Colors.base 
            font.pixelSize: Options.font.size
            font.family: Options.font.family
            font.bold: true
            // scrollDuration: 5000  // Faster scroll
            dwellTime: 4000
            text: Players.songInfo
        }


        BarPopup {
            id: popup
            target: root
            bar: root.bar
            // panel lives inside the content Component, so read its size via contentItem
            implicitWidth: contentItem ? contentItem.implicitWidth : 0
            // Window: a fixed, tall-enough size, set once when it maps. It doesn't resize
            // reliably afterwards, and the panel's layout is still settling at that moment.
            implicitHeight: contentItem ? contentItem.maxHeight : 0
            // Visible body: follows the panel's real height.
            bodyHeight: contentItem ? contentItem.implicitHeight : 0

            PlayerPanel {
                anchors.fill: parent
            }
        }
    }
}
