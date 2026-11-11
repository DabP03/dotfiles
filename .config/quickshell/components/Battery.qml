import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets
import Quickshell.Hyprland

import "../config/"
import "../services/"
import "../widgets/"

Rectangle {
    id: root
    required property var bar
    required property bool barDocked
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: icon.implicitWidth + percent.implicitWidth * Power.isLaptopBattery + 8 + 16 * !Power.isLaptopBattery
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
                duration: Motion.micro
                easing.type: Motion.arrive
            }
        }

        RowLayout {
            anchors {
                centerIn: parent
            }
            spacing: -8

            Icon {
                id: icon
                color: Colors.base 
                bottomPadding: 2
                fill: 1
                text: Power.icon
            }

            Text {
                id: percent
                visible: Power.isLaptopBattery
                color: Colors.base 
                font.pixelSize: Options.font.size
                font.family: Options.font.family
                font.bold: true
                text: " " + Math.round(Power.percentage * 100) + "%"
            }
        }

        BarPopup {
            id: popup
            target: root
            bar: root.bar
            implicitHeight: contentItem ? contentItem.fullHeight : 0
            implicitWidth: contentItem ? contentItem.fullWidth : 0

            Rectangle {
                id: menu
                anchors.fill: parent
                color: Colors.base
                radius: Options.radius
                border.color: Colors.peach
                border.width: Options.borderWidth
                topLeftRadius: 0
                topRightRadius: 0

                // read by the popup through contentItem
                readonly property real fullHeight: performance.implicitHeight + balanced.implicitHeight + saver.implicitHeight + 10 * 3
                    + (timeToEmpty.implicitHeight + 10) * timeToEmpty.visible
                readonly property real fullWidth: Math.max(timeToEmpty.implicitWidth * Power.isLaptopBattery, performance.implicitWidth + 10) + 20

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
                        top: parent.top
                    }
                    spacing: 10

                    Text {
                        id: timeToEmpty
                        color: Colors.text
                        font.pixelSize: Options.font.size - 2
                        font.family: Options.font.family
                        font.bold: true

                        text: if (Power.charging) {
                            return " " + Math.floor(Power.timeToFull / 3600) + ":" + (Math.floor(Power.timeToFull / 60) % 60).toString().padStart(2, '0') + "h"
                        } else {
                            return " " + Math.floor(Power.timeToEmpty / 3600) + ":" + (Math.floor(Power.timeToEmpty / 60) % 60).toString().padStart(2, '0') + "h"
                        }

                    }

                    // Profiles are a stack of equal tiles; the selected one is
                    // marked by a pill that travels down the stack instead of
                    // every tile repainting.
                    Item {
                        id: profileRow
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: performance.implicitWidth
                        Layout.preferredHeight: 3 * performance.implicitHeight + 2 * 8

                        readonly property int step: performance.implicitHeight + 8
                        readonly property int profileIndex: {
                            if (Power.profile === PowerProfile.Performance)
                                return 0;
                            if (Power.profile === PowerProfile.PowerSaver)
                                return 2;
                            return 1;
                        }

                        Rectangle {
                            id: profilePill
                            width: performance.implicitWidth
                            height: performance.implicitHeight
                            radius: Options.buttonRadius
                            color: Colors.green
                            y: profileRow.profileIndex * profileRow.step

                            Behavior on y {
                                NumberAnimation {
                                    duration: Motion.slide
                                    easing.type: Motion.arrive
                                }
                            }
                        }

                        StyledButton {
                            id: performance
                            implicitWidth: (performance.textWidth + 25)
                            implicitHeight: root.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: containsMouse ? Colors.green : "transparent"
                            buttonTextColor: Power.profile === PowerProfile.Performance || containsMouse ? Colors.base : Colors.green
                            buttonText: "electric_bolt"
                            fontFamily: Options.font.iconFamily
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.Performance
                            }
                        }

                        StyledButton {
                            id: balanced
                            implicitWidth: performance.implicitWidth
                            implicitHeight: performance.implicitHeight
                            radius: Options.buttonRadius
                            anchors.top: performance.bottom
                            anchors.topMargin: 8
                            buttonColor: containsMouse ? Colors.green : "transparent"
                            buttonTextColor: Power.profile === PowerProfile.Balanced || containsMouse ? Colors.base : Colors.green
                            buttonText: "balance"
                            fontFamily: Options.font.iconFamily
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.Balanced
                            }
                        }

                        StyledButton {
                            id: saver
                            implicitWidth: performance.implicitWidth
                            implicitHeight: performance.implicitHeight
                            radius: Options.buttonRadius
                            anchors.top: balanced.bottom
                            anchors.topMargin: 8
                            buttonColor: containsMouse ? Colors.green : "transparent"
                            buttonTextColor: Power.profile === PowerProfile.PowerSaver || containsMouse ? Colors.base : Colors.green
                            buttonText: "nest_eco_leaf"
                            fontFamily: Options.font.iconFamily
                            onClick: () => {
                                PowerProfiles.profile = PowerProfile.PowerSaver
                            }
                        }
                    }
                }
            }
        }
    }
}
