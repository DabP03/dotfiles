import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

ColumnLayout {
    id: root
    required property PwNode node;
    required property string name;
    property real sliderScale: 1.0
    property bool containsMouse: (!decButton.containsMouse && !incButton.containsMouse && !slider.hovered && !audioSinkPercent.containsMouse)

    spacing: 4

    PwObjectTracker { objects: [ node ] }

    ScrollingText {
        id: audioSinkName
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: {
            let cap = 200 * root.sliderScale
            return textWidth < cap ? textWidth : cap
        }
        color: Colors.text
        font.bold: true
        font.pixelSize: Options.font.size - 2
        font.family: Options.font.family
        text: name || node.properties["application.name"] || node.nickname || "Unknown"
        dwellTime: 3000
    }

    RowLayout {
        id: panelRow
        Layout.alignment: Qt.AlignHCenter
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
            implicitWidth: 200 * root.sliderScale
            from: 0
            value: Math.round(node.audio.volume * 100) / 100
            to: 1
            onMoved: () => {
                Audio.setVolume(slider.position, node)
            }
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200 * root.sliderScale
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
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: textWidth + 8
        implicitHeight: 20
        buttonColor: Colors.base
        buttonTextColor: Colors.text
        buttonText: Math.round(node.audio.volume * 100) + "%"
        onClick: () => {
            Audio.mute(node)
        }
    }
}
