import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

import "../config/"
import "../services/"
import "../widgets/"

ColumnLayout {
    id: root
    required property PwNode node;
    required property string name;
    required property int sliderWidth;

    property int buttonSize: 24
    property color buttonColor: Colors.peach
    property color buttonTextColor: Colors.base
    property bool percentBold: false
    property real sliderScale: 1.0
    property color sliderColor: Colors.peach
    property bool containsMouse: (!decButton.containsMouse && !incButton.containsMouse && !slider.hovered && !audioSinkPercent.containsMouse)

    spacing: 4

    // Node properties are tracked centrally by Audio.qml.

    // ScrollingText {
    //     id: audioSinkName
    //     Layout.alignment: Qt.AlignHCenter
    //     implicitWidth: {
    //         let cap = 200 * root.sliderScale
    //         return textWidth < cap ? textWidth : cap
    //     }
    //     color: Colors.text
    //     font.bold: true
    //     font.pixelSize: Options.font.size - 2
    //     font.family: Options.font.family
    //     text: name || node.properties["application.name"] || node.nickname || "Unknown"
    //     dwellTime: 3000
    // }

    RowLayout {
        id: panelRow
        Layout.alignment: Qt.AlignHCenter
        spacing: 4

        StyledButton {
            id: decButton
            implicitWidth: root.buttonSize
            implicitHeight: root.buttonSize
            buttonColor: root.buttonColor
            buttonTextColor: root.buttonTextColor
            buttonText: "-"
            onClick: () => {
                Audio.decrement(node)
            }
        }

        Slider {
            id: slider
            implicitWidth: (root.sliderWidth - (root.buttonSize * 3) - (4 * 4) - audioSinkPercent.width) * root.sliderScale
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
                    color: root.sliderColor
                    radius: 2
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 13
                color: slider.pressed ? Qt.lighter(root.sliderColor, 1.1) : root.sliderColor
            }
        }

        Text {
            id: audioSinkPercent
            Layout.alignment: Qt.AlignVCenter
            color: Colors.text
            font.bold: root.percentBold
            text: Math.round(node.audio.volume * 100) + "%"
        }
        StyledButton {
            id: incButton
            implicitWidth: root.buttonSize
            implicitHeight: root.buttonSize
            buttonColor: root.buttonColor
            buttonTextColor: root.buttonTextColor
            buttonText: "+"
            onClick: () => {
                Audio.increment(node)
            }
        }

    }

}
