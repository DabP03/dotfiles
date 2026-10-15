import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets
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
        let width = icon.implicitWidth + 25
        Options.width.battery = width;
        return width;
    } 
    radius: 8

    MouseArea {
        id: mouseArea1
        anchors.fill: parent
        hoverEnabled: true // Needed for scroll wheel detection

        onClicked: popup.toggle()
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: mouseArea1.containsMouse ? Qt.lighter(Colors.green, 1.1) : Colors.green

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut // Smooth easing curve
            }
        }

        Text {
            id: icon
            color: Colors.base 
            font.pixelSize: Options.font.size
            font.family: Options.font.iconFamily
            font.bold: true
            anchors.centerIn: parent
            text: {
                let text = Power.icon
                if (Power.isLaptopBattery) {
                    text += " " + Math.round(Power.percentage * 100) + "%"
                }
                return text
            } 
        }

        BarPopup {
            id: popup
            target: root
            bar: root.bar
            implicitHeight: performance.implicitHeight + balanced.implicitHeight + saver.implicitHeight + 10 * 3 + (timeToEmpty.implicitHeight) * timeToEmpty.visible
            implicitWidth: Math.max((timeToEmpty.implicitWidth) * Power.isLaptopBattery, performance.implicitWidth + 10) + 20

            Rectangle {
                id: menu
                property bool shown: false
                anchors.topMargin: 10
                color: Colors.base
                radius: Options.radius
                border.color: Colors.peach
                border.width: Options.borderWidth
                topLeftRadius: 0
                topRightRadius: 0
                implicitHeight: popup.implicitHeight
                implicitWidth: popup.implicitWidth
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Options.easingTypeOut
                    }
                }

                Rectangle {
                    id: topBorder
                    width: parent.width - Options.borderWidth * 2
                    height: Options.borderWidth
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.base
                }

                ColumnLayout {
                    id: baterryItems
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        // verticalCenter: parent.verticalCenter
                        top: parent.top
                    }
                    spacing: 10

                    Text {
                        // anchors {
                        //     horizontalCenter: parent.horizontalCenter
                        // }
                        id: timeToEmpty
                        visible: Power.isLaptopBattery
                        color: Colors.text
                        font.pixelSize: Options.font.size - 2
                        font.family: Options.font.family
                        font.bold: true

                        text: if (Power.charging) {
                            return " " + Math.floor(Power.timeToFull / 3600) + ":" + (Math.floor(Power.timeToFull / 60) % 60).toString().padStart(2, '0') + "h"
                        } else {
                            return " " + Math.floor(Power.timeToEmpty / 3600) + ":" + (Math.floor(Power.timeToEmpty / 60) % 60).toString().padStart(2, '0') + "h"
                        }

                    }

                    ColumnLayout {
                        id: column
                        // anchors {
                        //     horizontalCenter: parent.horizontalCenter
                        //     // verticalCenter: parent.verticalCenter
                        // }
                        spacing: 8

                        StyledButton {
                            id: performance
                            implicitWidth: (performance.textWidth + 25)
                            implicitHeight: root.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: {
                                if (Power.profile == PowerProfile.Performance) {
                                    return containsMouse ? Qt.lighter(Colors.green, 1.1) : Colors.green 
                                } else {
                                    return containsMouse ? Colors.green : Colors.base
                                }
                            }
                            buttonTextColor: Power.profile == PowerProfile.Performance || containsMouse ? Colors.base : Colors.green
                            buttonText: ""
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.Performance
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100 // Transition duration in milliseconds
                                    easing.type: Options.easingTypeIn // Smooth easing curve
                                }
                            }
                        }

                        StyledButton {
                            id: balanced
                            implicitWidth: (performance.textWidth + 25)
                            implicitHeight: root.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: {
                                if (Power.profile == PowerProfile.Balanced) {
                                    return containsMouse ? Qt.lighter(Colors.green, 1.1) : Colors.green 
                                } else {
                                    return containsMouse ? Colors.green : Colors.base
                                }
                            }
                            buttonTextColor: Power.profile == PowerProfile.Balanced || containsMouse ? Colors.base : Colors.green
                            buttonText: ""
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.Balanced
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100 // Transition duration in milliseconds
                                    easing.type: Options.easingTypeIn // Smooth easing curve
                                }
                            }
                        }

                        StyledButton {
                            id: saver
                            implicitWidth: (performance.textWidth + 25)
                            implicitHeight: root.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: {
                                if (Power.profile == PowerProfile.PowerSaver) {
                                    return containsMouse ? Qt.lighter(Colors.green, 1.1) : Colors.green 
                                } else {
                                    return containsMouse ? Colors.green : Colors.base
                                }
                            }
                            buttonTextColor: Power.profile == PowerProfile.PowerSaver || containsMouse ? Colors.base : Colors.green
                            buttonText: ""
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.PowerSaver
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100 // Transition duration in milliseconds
                                    easing.type: Options.easingTypeIn // Smooth easing curve
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
