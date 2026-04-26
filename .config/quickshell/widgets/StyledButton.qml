import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/config/"

Rectangle {
    id: root
    color: "transparent"
    readonly property bool containsMouse: mouseArea.containsMouse
    readonly property var textWidth: icon.implicitWidth
    required property var onClick
    required property var buttonColor
    required property var buttonText
    required property var buttonTextColor

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true // Needed for scroll wheel detection

        onClicked: () => {
            root.onClick()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Options.buttonRadius
        color: mouseArea.containsMouse ? Qt.lighter(root.buttonColor, 1.1) : root.buttonColor

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut // Smooth easing curve
            }
        }

        Text {
            id: icon
            color: root.buttonTextColor
            font.pixelSize: Options.font.size
            font.family: Options.font.family
            font.bold: true
            anchors.centerIn: parent
            text: root.buttonText
        }
    }
}
