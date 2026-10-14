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
            implicitWidth: 300 + 8
            implicitHeight: 460

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
                    implicitHeight: 256
                    implicitWidth: 256
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

                RowLayout {
                    id: controlButtons
                    spacing: 4
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: durationRow.bottom
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
                        buttonText: Players.active.playbackState.toString() == 1 ? "\uf04c" : "\uf04b"
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

                RowLayout {
                    id: durationRow
                    spacing: 6
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: albumName.bottom
                        topMargin: 8
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: Players.formatTime(Players.active.position)
                        color: Colors.text
                        font.pixelSize: Options.font.size - 2
                        font.family: Options.font.family
                    }

                    Slider {
                        id: durationSlider
                        implicitWidth: 180
                        from: 0
                        to: Players.active.length > 0 ? Players.active.length : 1
                        enabled: Players.active.canSeek

                        // Imperative updates (not a binding) so dragging the handle
                        // doesn't fight with position ticks arriving during the seek.
                        Component.onCompleted: value = Players.active.position

                        Connections {
                            target: Players.active
                            function onPositionChanged() {
                                if (!durationSlider.pressed) {
                                    durationSlider.value = Players.active.position
                                }
                            }
                            function onTrackChanged() {
                                durationSlider.value = Players.active.position
                            }
                        }

                        onMoved: () => {
                            Players.active.position = durationSlider.value
                        }
                        background: Rectangle {
                            x: durationSlider.leftPadding
                            y: durationSlider.topPadding + durationSlider.availableHeight / 2 - height / 2
                            implicitWidth: 180
                            implicitHeight: 4
                            width: durationSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: Colors.surface0
                            Rectangle {
                                width: durationSlider.visualPosition * parent.width
                                height: parent.height
                                color: Colors.yellow
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: durationSlider.leftPadding + durationSlider.visualPosition * (durationSlider.availableWidth - width)
                            y: durationSlider.topPadding + durationSlider.availableHeight / 2 - height / 2
                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 13
                            color: durationSlider.pressed ? Qt.lighter(Colors.yellow, 1.1) : Colors.yellow
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: Players.formatTime(Players.active.length)
                        color: Colors.text
                        font.pixelSize: Options.font.size - 2
                        font.family: Options.font.family
                    }
                }

                RowLayout {
                    id: bottomButtons
                    spacing: 8
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: controlButtons.bottom
                        topMargin: 8
                    }

                    Rectangle {
                        id: sourceRect
                        implicitHeight: 30
                        implicitWidth: sourceRow.implicitWidth + 16
                        radius: Options.radius
                        color: Colors.mantle

                        RowLayout {
                            id: sourceRow
                            anchors.centerIn: parent

                            spacing: 4

                            Rectangle {
                                id: playerImgContainer
                                implicitHeight: 24
                                implicitWidth: 24
                                color: "transparent"
                                Image {
                                    id: playerImg
                                    anchors.fill: parent
                                    source: Quickshell.iconPath(Players.getSourceIcon(Players.active.identity))
                                }
                            }

                            Text {
                                text: Players.getSourceName(Players.active.identity)
                                color: Colors.text
                                font.bold: true
                                font.pixelSize: Options.font.size - 2
                                font.family: Options.font.family
                            }
                        }
                    }
                }
            }
        }
    }
}
