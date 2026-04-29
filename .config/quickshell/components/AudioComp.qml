import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    required property bool barDocked
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: {
        let width = audioText.implicitWidth + audioIcon.implicitWidth + micIcon.implicitWidth + micText.implicitWidth + separator.implicitWidth + 30
        Options.width.audio = width
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
        id: mouseArea1
        implicitWidth: parent.implicitWidth / 2
        implicitHeight: parent.implicitHeight
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        hoverEnabled: true
        onWheel: (event) => {
            event.accepted = true // Prevent default scroll behavior
            let increment = event.angleDelta.y > 0 ? 0.05 : -0.05
            let newVolume = Math.max(0, Math.min(1, Audio.volume + increment))
            Audio.setVolume(newVolume)
        }
        onClicked: (event) => {
            if (dynamicLoader.active) {
                dynamicLoader.active = false  // Hide/destroy
            } else {
                dynamicLoader.active = true   // Create/show
            }
        }
    }

    MouseArea {
        id: mouseArea2
        implicitWidth: parent.implicitWidth / 2
        implicitHeight: parent.implicitHeight
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        hoverEnabled: true
        onWheel: (event) => {
            event.accepted = true // Prevent default scroll behavior
            let increment = event.angleDelta.y > 0 ? 0.05 : -0.05
            let newVolume = Math.max(0, Math.min(1, Audio.micVolume + increment))
            Audio.setVolume(newVolume, Audio.source)
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
        anchors.fill: parent
        radius: 8
        color: (mouseArea1.containsMouse || mouseArea2.containsMouse) ? Qt.lighter(Colors.teal, 1.1) : Colors.teal

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut // Smooth easing curve
            }
        }

        RowLayout {
            id: audioRow
            anchors.centerIn: parent

            RowLayout {
                spacing: -4
                Text {
                    id: audioIcon
                    color: Colors.base
                    font.bold: true
                    font.pixelSize: Options.font.size
                    font.family: Options.font.family
                    text: {
                        if (Audio.muted) return "󰝟 "
                        else if (Audio.volume < .25) return "󰕿 "
                        else if (Audio.volume < .50) return "󰖀 "
                        else return "󰕾 "
                    }
                }

                Text {
                    id: audioText
                    color: Colors.base
                    font.bold: true
                    font.pixelSize: Options.font.size
                    font.family: Options.font.family
                    text: {
                        if (Audio.muted) return (Math.round(Audio.volume * 100)) + "%"
                        else if (Audio.volume < .25) return (Math.round(Audio.volume * 100)) + "%"
                        else if (Audio.volume < .50) return (Math.round(Audio.volume * 100)) + "%"
                        else return (Math.round(Audio.volume * 100)) + "%"
                    }
                }
            }

            Text {
                id: separator
                color: Colors.base
                font.bold: true
                font.pixelSize: Options.font.size
                font.family: Options.font.family
                text: "|"
            }

            RowLayout {
                spacing: 2
                Text {
                    id: micIcon
                    color: Colors.base
                    font.bold: true
                    font.pixelSize: Options.font.size
                    font.family: Options.font.family
                    text: {
                        if (Audio.micMuted || Audio.micVolume <= 0) return ""
                        else return ""
                    }
                }

                Text {
                    id: micText
                    color: Colors.base
                    font.bold: true
                    font.pixelSize: Options.font.size
                    font.family: Options.font.family
                    text: {
                        if (Audio.micMuted) return (Math.round(Audio.micVolume * 100)) + "%"
                        else if (Audio.micVolume < .25) return (Math.round(Audio.micVolume * 100)) + "%"
                        else if (Audio.micVolume < .50) return (Math.round(Audio.micVolume * 100)) + "%"
                        else return (Math.round(Audio.micVolume * 100)) + "%"
                    }
                }
            }
        }

        Loader {
            id: dynamicLoader
            active: false  // Starts hidden
            sourceComponent: PanelWindow {
                id: playerPanel
                implicitHeight: topBorder.implicitHeight + mixerMain.implicitHeight + mixerMainMic.implicitHeight + (separator.implicitHeight * (repeater.count != 0)) + (mixerMain.implicitHeight * (repeater.count != 0)) + (10 * (repeater.count != 0))
                implicitWidth: 200

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
                    + (Options.margin.inner * 4 + Options.margin.inner * root.barDocked)
                    + Options.width.audio
                    - playerPanel.implicitWidth
                    + (playerPanel.implicitWidth - Options.width.audio)
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

                    MouseArea {
                        id: mouseAreaLoader
                        anchors.fill: parent
                        hoverEnabled: true
                        onExited: {
                            if (!mouseAreaLoader.containsMouse && mixerMain.containsMouse && mixerMainMic.containsMouse && repeater.itemsContainMouse() && !scrollView.hovered) {
                                dynamicLoader.active = false
                            }
                        }
                    }

                    Rectangle {
                        id: topBorder
                        implicitWidth: parent.width - Options.borderWidth * 2
                        implicitHeight: Options.borderWidth
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Colors.base
                    }

                    PwNodeLinkTracker {
                        id: linkTracker
                        node: Pipewire.defaultAudioSink
                    }

                    MixerEntry {
                        id: mixerMain
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: topBorder.bottom
                            // topMargin: 35
                        }
                        node: Audio.sink
                        name: Audio.sink.nickname
                    }

                    MixerEntry {
                        id: mixerMainMic
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: mixerMain.bottom
                            // topMargin: 35
                        }
                        node: Audio.source
                        name: Audio.source.nickname
                    }

                    Rectangle {
                        id: separator
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: mixerMainMic.bottom
                            // topMargin: 35
                        }
                        implicitHeight: 3
                        implicitWidth: playerMenu.implicitWidth * .9
                        color: Colors.peach
                    }

                    ScrollView {
                        id: scrollView
                        implicitWidth: playerPanel.implicitWidth - 2
                        implicitHeight: mixerMain.implicitHeight
                        clip: false
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: separator.bottom
                            topMargin: 4
                        }
                        // onHoveredChanged: {
                        //     console.log("DOWN")
                        //     console.log("area: " + !mouseAreaLoader.containsMouse)
                        //     console.log("mixer: " + mixerMain.containsMouse)
                        //     console.log("repeater: " + repeater.itemsContainMouse())
                        //     console.log("scroll: " + !scrollView.hovered)
                        //     if (!mouseAreaLoader.containsMouse && mixerMain.containsMouse && repeater.itemsContainMouse() && !scrollView.hovered) {
                        //         dynamicLoader.active = false
                        //     }
                        // }
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        // ScrollBar.vertical: ScrollBar {}

                        ColumnLayout {
                            id: repeaterColumn
                            spacing: 4
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }

                            Repeater {
                                id: repeater
                                model: linkTracker.linkGroups

                                function itemsContainMouse() {
                                    let sharedState = false
                                    for (let i = 0; i < repeater.count; i++) {
                                        let item = repeater.itemAt(i)
                                        sharedState = sharedState || item.containsMouse
                                    }
                                    return sharedState
                                }

                                MixerEntry {
                                    required property PwLinkGroup modelData
                                    // Each link group contains a source and a target.
                                    // Since the target is the default sink, we want the source.
                                    node: modelData.source
                                    name: ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
