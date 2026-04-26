import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    color: "transparent"
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
        onClicked: (event) => {
            if (dynamicLoader.active) {
                dynamicLoader.active = false  // Hide/destroy
            } else {
                dynamicLoader.active = true   // Create/show
            }
        }
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
            implicitWidth: parent.implicitWidth + 4
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
            width: 28
            imgSource: Players.active.trackArtUrl
            radius: Options.radius
        }

        Text {
            id: playPauseIcon
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
            opacity: 0

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

                onTriggered: if (Players.active.playbackState == MprisPlaybackState.Playing) playPauseIcon.opacity = 0
            }

            onTextChanged: {
                opacity = 1
                playPauseTimer.restart()
            }

        }


        ScrollingText {
            id: songInfo
            implicitWidth: textWidth < 300 ? textWidth : 300
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

        Loader {
            id: dynamicLoader
            active: false  // Starts hidden
            sourceComponent: PanelWindow {
                id: playerPanel
                implicitHeight: 272
                implicitWidth: Math.max(192, songName.implicitWidth, authorName.implicitWidth, albumName.implicitWidth) + 8

                exclusionMode: ExclusionMode.Normal
                anchors {
                    top: true
                    right: true
                }
                margins {
                    top: -2
                    // wtf
                    right: Options.width.dash
                        + Options.width.network
                        + Options.width.audio
                        + (Options.margin.inner * 6 + Options.margin.inner * root.barDocked)
                        + Options.width.battery 
                        + Options.width.player 
                        - playerPanel.implicitWidth 
                        + (playerPanel.implicitWidth - Options.width.player) 
                        / 2
                }
                color: "transparent"

                Rectangle {
                    id: playerMenu
                    anchors.fill: parent
                    color: Colors.base
                    radius: Options.radius
                    topLeftRadius: 0
                    topRightRadius: 0
                    border.color: Colors.peach
                    border.width: Options.borderWidth
                    implicitHeight: playerPanel.implicitHeight
                    implicitWidth: playerPanel.implicitWidth


                    Rectangle {
                        id: topBorder
                        width: parent.width - Options.borderWidth * 2
                        height: Options.borderWidth
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Colors.base
                    }

                    RoundedImage {
                        id: menuSongImg
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 0
                        }
                        implicitHeight: 142
                        implicitWidth: 142
                        imgSource: Players.active.trackArtUrl
                        radius: Options.radius
                    }



                    ScrollingText {
                        id: songName
                        implicitWidth: textWidth < 300 ? textWidth : 300
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: menuSongImg.bottom
                            topMargin: 4
                        }
                        color: Colors.yellow
                        font.pixelSize: Options.font.size
                        font.family: Options.font.family
                        font.bold: true
                        // scrollDuration: 5000  // Faster scroll
                        dwellTime: 4000
                        text: Players.active.trackTitle
                    }

                    ScrollingText {
                        id: authorName
                        implicitWidth: textWidth < 300 ? textWidth : 300
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: songName.bottom
                            topMargin: 2
                        }
                        color: Colors.text
                        font.bold: true
                        font.pixelSize: Options.font.size
                        font.family: Options.font.family
                        // scrollDuration: 5000  // Faster scroll
                        dwellTime: 4000
                        text: Players.active.trackArtist
                    }

                    ScrollingText {
                        id: albumName
                        implicitWidth: textWidth < 300 ? textWidth : 300
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: authorName.bottom
                            topMargin: 2
                        }
                        color: Colors.text
                        font.pixelSize: Options.font.size
                        font.family: Options.font.family
                        // scrollDuration: 5000  // Faster scroll
                        dwellTime: 4000
                        text: Players.active.trackAlbum
                    }

                    MouseArea {
                        id: mouseAreaLoader
                        anchors.fill: parent
                        hoverEnabled: true
                        onExited: {
                            if (!mouseAreaLoader.containsMouse 
                            && !prevButton.containsMouse 
                            && !stopStartButton.containsMouse 
                            && !nextButton.containsMouse 
                            && !shuffleButton.containsMouse 
                            && !loopButton.containsMouse) {
                                dynamicLoader.active = false
                            }
                        }
                    }
                    RowLayout {
                        id: controlButtons
                        spacing: 4
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: albumName.bottom
                            topMargin: 8
                        }

                        StyledButton {
                            id: shuffleButton
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            buttonText: Players.active.shuffle ? "󰒟" : "󰒞"
                            onClick: () => {
                                Players.shuffle()
                            }
                        }

                        StyledButton {
                            id: prevButton
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            buttonText: ""
                            onClick: () => {
                                Players.previous()
                            }
                        }

                        StyledButton {
                            id: stopStartButton
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            buttonText: Players.active.playbackState.toString() == 1 ? "" : ""
                            onClick: () => {
                                Players.playPause()
                            }
                        }

                        StyledButton {
                            id: nextButton
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            buttonText: ""
                            onClick: () => {
                                Players.next()
                            }
                        }

                        StyledButton {
                            id: loopButton
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            buttonText: {
                                let loopState = Players.active.loopState.toString()
                                if (loopState == 0) {
                                    return "󰑗"
                                } else if (loopState == 1) {
                                    return "󰑘"
                                } else
                                    return "󰑖"
                                }
                            onClick: () => {
                                Players.loop()
                            }
                        }
                    }
                }
            }
        }
    }
}
