import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    color: "transparent"
    required property var bar
    required property bool barDocked
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: {
        let width = (songInfo.implicitWidth + 28 + 8 + 20) * (Players.active != null)
        Options.width.player = width
        return width
    }
    radius: 8

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Options.easingTypeOut
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
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeIn // Smooth easing curve
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
                    duration: 500 
                    easing.type: Options.easingTypeInOut
                } 
            }
            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 150  // Quick but smooth—adjust as needed
                    easing.type: Options.easingTypeInOut  // Balanced easing
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
            imgSource: Players.active.trackArtUrl
            radius: Options.radius
        }

        Text {
            id: playPauseIcon
            property bool playPauseVisible: false
            anchors {
                verticalCenter: songImg.verticalCenter
                horizontalCenter: songImg.horizontalCenter
            }
            text: if (Players.active.canPlay && Players.active.canPause && Players.active.canControl) {
                if (Players.active.playbackState == MprisPlaybackState.Playing) {
                    return ""
                } else {
                    return ""
                }
            }
            color: Colors.yellow
            style: Text.Outline; styleColor: Colors.base
            font.pixelSize: Options.font.size + 4
            font.family: Options.font.family
            font.bold: true
            opacity: (playPauseVisible && Players.active != null) ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 500 
                    easing.type: Options.easingTypeInOut
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
            implicitWidth: panel.implicitWidth
            implicitHeight: panel.implicitHeight

            PlayerPanel {
                id: panel
                anchors.fill: parent
            }
        }
    }
}
