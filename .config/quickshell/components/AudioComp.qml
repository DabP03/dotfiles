import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    required property var bar
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
        onClicked: popup.toggle()
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
        onClicked: popup.toggle()
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

        BarPopup {
            id: popup
            visible: false
            target: root
            bar: root.bar
            implicitHeight: topBorder.implicitHeight + 8 + mainRow.implicitHeight + (separator.implicitHeight * (repeater.count != 0)) + (scrollView.implicitHeight * (repeater.count != 0)) + (16 * (repeater.count != 0))
            implicitWidth: Math.max(220, mainRow.implicitWidth + 24, repeaterColumn.implicitWidth + 24)

                Rectangle {
                    id: playerMenu
                    anchors.fill: parent
                    color: Colors.base
                    radius: Options.radius
                    topLeftRadius: 0
                    topRightRadius: 0
                    border.color: Colors.peach
                    border.width: Options.borderWidth
                    implicitHeight: popup.implicitHeight
                    implicitWidth: popup.implicitWidth

                    Rectangle {
                        id: topBorder
                        implicitWidth: parent.width - Options.borderWidth * 2
                        implicitHeight: Options.borderWidth
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Colors.base
                    }

                    ColumnLayout {
                        id: mainRow
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: topBorder.bottom
                            topMargin: 8
                        }
                        spacing: 8

                        ColumnLayout {
                            id: outputColumn
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Output"
                                color: Colors.text
                                opacity: 0.6
                                font.bold: true
                                font.pixelSize: Options.font.size - 3
                                font.family: Options.font.family
                            }

                            MixerEntry {
                                id: mixerMain
                                node: Audio.sink
                                name: Audio.sink.nickname
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            implicitHeight: Options.borderWidth
                            color: Colors.surface0
                        }

                        ColumnLayout {
                            id: inputColumn
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Input"
                                color: Colors.text
                                opacity: 0.6
                                font.bold: true
                                font.pixelSize: Options.font.size - 3
                                font.family: Options.font.family
                            }

                            MixerEntry {
                                id: mixerMainMic
                                node: Audio.source
                                name: Audio.source.nickname
                            }
                        }
                    }

                    Rectangle {
                        id: separator2
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: mainRow.bottom
                            topMargin: 8
                        }
                        implicitHeight: 3
                        implicitWidth: playerMenu.implicitWidth * .9
                        color: Colors.peach
                    }

                    ScrollView {
                        id: scrollView
                        implicitWidth: popup.implicitWidth - 2
                        implicitHeight: Math.min(repeaterColumn.implicitHeight, 220)
                        clip: false
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: separator2.bottom
                            topMargin: 4
                        }

                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        ColumnLayout {
                            id: repeaterColumn
                            spacing: 12
                            anchors {
                                top: parent.top
                                horizontalCenter: parent.horizontalCenter
                            }

                            Repeater {
                                id: repeater
                                model: Audio.groupedSinks

                                function itemsContainMouse() {
                                    let sharedState = false
                                    for (let i = 0; i < repeater.count; i++) {
                                        let item = repeater.itemAt(i)
                                        sharedState = sharedState || (item && item.containsMouse)
                                    }
                                    return sharedState
                                }


                                ColumnLayout {
                                    id: groupDelegate
                                    required property var modelData
                                    required property int index
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 16

                                    property bool containsMouse: groupItem.containsMouse

                                    MixerGroup {
                                        id: groupItem
                                        appName: groupDelegate.modelData.appName
                                        nodes: groupDelegate.modelData.nodes
                                    }

                                    Rectangle {
                                        visible: groupDelegate.index < repeater.count - 1
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 24
                                        implicitHeight: Options.borderWidth
                                        color: Colors.surface0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
