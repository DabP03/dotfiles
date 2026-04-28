import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    color: Colors.blue
    height: parent.height - 16
    implicitWidth: {
        let width = 0
        if (name.shown) {
            width = symbol.width + name.width + 10;
        } else {
            width = symbol.width + 4;
        }
        Options.width.network = width
        return width
    } 
    radius: 8

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 175 
            easing.type: Options.easingTypeOut
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        function handleClicked(event) {
            name.shown = !name.shown // Toggle visibility
        }

        onClicked: (event) => handleClicked(event)        
    }

    
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: mouseArea.containsMouse ? Qt.lighter(Colors.blue, 1.1) : Colors.blue

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Easing.Linear // Smooth easing curve
            }
        }

        RowLayout {
            id: row
            spacing: -10
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 15
            }

            Text {
                id: symbol
                color: Colors.base
                font.family: Options.font.iconFamily
                font.bold: true
                font.pixelSize: Options.font.size + 2
                text: Network.symbol
            }

            Text {
                id: name
                property bool shown: false

                Behavior on visible { NumberAnimation { duration: 150 } }

                visible: shown
                color: Colors.base
                font.bold: true
                font.family: Options.font.family
                font.pixelSize: Options.font.size
                text: Network.networkName
            }
        }
    }
}
