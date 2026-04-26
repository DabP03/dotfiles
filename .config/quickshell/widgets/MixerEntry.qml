import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    required property PwNode node;
    required property string name;
    property bool containsMouse: (!decButton.containsMouse && !incButton.containsMouse && !slider.hovered && !audioSinkPercent.containsMouse)

    implicitHeight: audioSinkName.implicitHeight + panelRow.implicitHeight + audioSinkPercent.implicitHeight + 4 + 4 * 2 + 4

    color: "transparent"

    PwObjectTracker { objects: [ node ] }

    ScrollingText {
        id: audioSinkName
        implicitWidth: textWidth < 200 ? textWidth : 200

        anchors {
            bottom: panelRow.top
            bottomMargin: 2
            horizontalCenter: parent.horizontalCenter
        }
        color: Colors.text
        font.bold: true
        font.pixelSize: Options.font.size - 2
        font.family: Options.font.family
        text: name || node.properties["application.name"] || "Unknown"
        dwellTime: 3000

    }

    RowLayout {
        id: panelRow
        implicitHeight: decButton.implicitHeight + slider.implicitHeight + incButton.implicitHeight
        anchors {
            centerIn: parent
        }
        spacing: 4

        StyledButton {
            id: decButton
            implicitWidth: 25
            implicitHeight: 25
            buttonColor: Colors.teal
            buttonTextColor: Colors.base
            buttonText: "-"
            onClick: () => {
                Audio.decrement(node)
            }
        }

        Slider {
            id: slider
            from: 0
            value: Math.round(node.audio.volume * 100) / 100
            to: 1
            onMoved: () => {
                Audio.setVolume(slider.position, node)
            }
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 100
                implicitHeight: 4
                width: slider.availableWidth
                height: implicitHeight
                radius: 2
                color: Colors.surface0
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: Colors.teal
                    radius: 2
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 13
                color: slider.pressed ? Qt.lighter(Colors.teal, 1.1) : Colors.teal
            }
        }

        StyledButton {
            id: incButton
            implicitWidth: 25
            implicitHeight: 25
            buttonColor: Colors.teal
            buttonTextColor: Colors.base
            buttonText: "+"
            onClick: () => {
                Audio.increment(node)
            }
        }
    }

    StyledButton {
        id: audioSinkPercent
        anchors {
            top: panelRow.bottom
            bottomMargin: 2
            horizontalCenter: parent.horizontalCenter
        }
        implicitWidth: textWidth + 8
        implicitHeight: 25
        buttonColor: Colors.base
        buttonTextColor: Colors.text
        buttonText: Math.round(node.audio.volume * 100) + "%"
        onClick: () => {
            Audio.mute(node)
        }
    }

    // Text {
    //     id: audioSinkPercent
    //     color: Colors.text
    //     font.bold: true
    //     font.pixelSize: Options.font.size - 2
    //     font.family: Options.font.family
    //     text: Math.round(node.audio.volume * 100) + "%"
    // }
}
