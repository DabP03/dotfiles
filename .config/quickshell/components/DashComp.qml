import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    required property bool barDocked
    required property var bar
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: {
        let width = icon.implicitWidth + 24;
        Options.width.dash = width;
        return width;
    } 
    radius: 8
    // Behavior on implicitWidth { NumberAnimation { duration: 175 } }

    MouseArea {
        id: mouseArea1
        anchors.fill: parent
        hoverEnabled: true // Needed for scroll wheel detection

        onClicked: popup.toggle()
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: mouseArea1.containsMouse ? Qt.lighter(Colors.lavender, 1.1) : Colors.lavender

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut // Smooth easing curve
            }
        }

        Text {
            id: icon
            color: Colors.base
            font.family: Options.font.family
            font.bold: true

            anchors.centerIn: parent
            text: Time.timeI
        }


        BarPopup {
            id: popup
            target: root
            bar: root.bar
            anchor.rect.x: root.bar.width - root.mapToItem(null, 0, 0).x - popup.implicitWidth / 2 - root.implicitWidth / 2
            // implicitWidth: calendarPanel.implicitWidth + 98 + 24
            implicitWidth: 425
            implicitHeight: calendarPanel.implicitHeight +  3 * (datePanel.implicitHeight + 6) + 24

            Rectangle {
                id: menu
                color: Colors.base
                radius: Options.radius
                border.color: Colors.peach
                border.width: Options.borderWidth
                topLeftRadius: 0
                topRightRadius: 0
                bottomRightRadius: 0
                implicitHeight: popup.implicitHeight
                implicitWidth: popup.implicitWidth

                Rectangle {
                    id: topBorder
                    width: parent.width - Options.borderWidth * 2
                    height: Options.borderWidth
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.base
                }

                Rectangle {
                    id: sideBorder
                    width: Options.borderWidth
                    height: parent.implicitHeight - 2

                    anchors.right: parent.right
                    anchors.top: parent.top
                    color: Colors.base
                }

                Process {
                    id: process
                }
                Rectangle {
                    id: calendarPanel
                    anchors {
                        top: dndPanel.bottom
                        left: parent.left
                        topMargin: 6
                        leftMargin: 12
                    }
                    color: Colors.mantle
                    radius: Options.radius
                    implicitHeight: calendar.height
                    implicitWidth: calendar.width

                    // Behavior on opacity {
                    //     NumberAnimation {
                    //         duration: 200
                    //         easing.type: Options.easingTypeOut
                    //     }
                    // }

                    Calendar {
                        id: calendar
                        anchors.margins: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }


                Rectangle {
                    id: datePanel
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 12
                        topMargin: 12
                    }

                    implicitHeight: buttonsPanel.implicitHeight
                    implicitWidth: (parent.implicitWidth - 24 - 3) / 2
                    radius: Options.radius
                    color: Colors.mantle

                    ColumnLayout {
                        id: datePanelLayout
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 12
                        }
                        spacing: 4

                        Text {
                            id: datePanelText
                            color: Colors.text
                            font.family: Options.font.family
                            font.bold: true
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignHCenter
                            text: Time.time
                        }

                        Text {
                            id: datePanelSubText
                            color: Colors.subtext0
                            font.family: Options.font.family
                            font.bold: false
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 14
                            text: Time.fancyDate
                        }
                    }

                }

                Rectangle {
                    id: buttonsPanel
                    anchors {
                        top: parent.top
                        left: datePanel.right
                        right: parent.right
                        leftMargin: 6
                        rightMargin: 12
                        topMargin: 12
                    }
                    color: Colors.mantle
                    radius: Options.radius
                    implicitHeight: power.implicitHeight + 28
                    implicitWidth: (parent.implicitWidth - 24 - 3) / 2

                    RowLayout {
                        id: column
                        spacing: 4
                        anchors {
                            centerIn: parent
                        }

                        StyledButton {

                            id: lock
                            implicitWidth: logout.implicitWidth
                            implicitHeight: logout.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: Colors.blue
                            buttonTextColor: Colors.base
                            fontSize: 18
                            fontFamily: Options.font.iconFamily
                            buttonText: "lock"
                            onClick: () => {
                                process.exec(["hyprlock"])
                            }
                        }

                        StyledButton {
                            id: logout
                            implicitWidth: (textWidth + 22)
                            implicitHeight: (textWidth + 22)
                            radius: Options.buttonRadius
                            buttonColor: Colors.green
                            buttonTextColor: Colors.base
                            fontFamily: Options.font.iconFamily
                            fontSize: 18
                            buttonText: "logout"
                            onClick: () => {
                                process.exec(["systemctl", "exit"])
                            }
                        }

                        StyledButton {
                            id: restart
                            implicitWidth: logout.implicitWidth
                            implicitHeight: logout.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: Colors.yellow
                            buttonTextColor: Colors.base
                            fontFamily: Options.font.iconFamily
                            fontSize: 18
                            buttonText: "restart_alt"
                            onClick: () => {
                                process.exec(["systemctl", "reboot"])
                            }
                        }

                        StyledButton {
                            id: power
                            implicitWidth: logout.implicitWidth
                            implicitHeight: logout.implicitHeight
                            radius: Options.buttonRadius
                            buttonColor: Colors.red
                            buttonTextColor: Colors.base
                            fontFamily: Options.font.iconFamily
                            buttonText: "mode_off_on"
                            fontSize: 18
                            onClick: () => {
                                process.exec(["systemctl", "poweroff"])
                            }
                        }
                    }
                }

                Rectangle {
                    id: idlePanel
                    anchors {
                        top: datePanel.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                        rightMargin: 12
                        topMargin: 6
                    }

                    implicitHeight: buttonsPanel.implicitHeight
                    implicitWidth: (parent.implicitWidth - 24 - 3) / 2
                    radius: Options.radius
                    color: Colors.mantle

                    Rectangle {
                        id: idleIconRect
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        implicitWidth: logout.implicitWidth
                        implicitHeight: logout.implicitHeight
                        color: idleSwitch.checked ? Colors.lavender : Colors.base
                        radius: Options.radius / 2

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Options.easingTypeOut
                            }
                        }

                        Icon { 
                            text: "coffee"
                            anchors {
                                centerIn: parent
                            }
                            color: idleSwitch.checked ? Colors.base : Colors.subtext0
                            font.pixelSize: 18

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                    easing.type: Options.easingTypeOut
                                }
                            }
                        }

                    }

                    ColumnLayout {
                        id: idleLayout
                        anchors {
                            verticalCenter: idleIconRect.verticalCenter
                            left: idleIconRect.right
                            leftMargin: 12
                            right: idleSwitch.left
                            rightMargin: 12
                        }

                        Text {
                            id: idleText
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            color: Colors.text
                            font.family: Options.font.family
                            font.bold: true
                            font.pixelSize: 18
                            text: "Idle Inhibitor" 
                        }

                        Text {
                            id: idleSubText
                            color: Colors.subtext0
                            font.family: Options.font.family
                            font.bold: false
                            font.pixelSize: 12
                            text: "Blocks lock and sleep" 
                        }
                    }

                    ToggleSwitch {
                        id: idleSwitch
                        backColor: Colors.lavender
                        anchors {
                            verticalCenter: idleIconRect.verticalCenter
                            rightMargin: 12
                            right: parent.right
                        }
                        checked: Idle.inhibitor.enabled
                        onClicked: Idle.inhibitor.toggle()
                    }
                }

                Rectangle {
                    id: dndPanel
                    anchors {
                        top: idlePanel.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                        rightMargin: 12
                        topMargin: 6
                    }

                    implicitHeight: buttonsPanel.implicitHeight
                    implicitWidth: (parent.implicitWidth - 24 - 3) / 2
                    radius: Options.radius
                    color: Colors.mantle

                    Rectangle {
                        id: dndIconRect
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        implicitWidth: logout.implicitWidth
                        implicitHeight: logout.implicitHeight
                        color: dndSwitch.checked ? Colors.lavender : Colors.base
                        radius: Options.radius / 2

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Options.easingTypeOut
                            }
                        }

                        Icon { 
                            text: "notifications"
                            anchors {
                                centerIn: parent
                            }
                            color: dndSwitch.checked ? Colors.base : Colors.subtext0
                            font.pixelSize: 18

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                    easing.type: Options.easingTypeOut
                                }
                            }
                        }

                    }

                    ColumnLayout {
                        id: dndLayout
                        anchors {
                            verticalCenter: dndIconRect.verticalCenter
                            left: dndIconRect.right
                            leftMargin: 12
                            right: dndSwitch.left
                            rightMargin: 12
                        }

                        Text {
                            id: dndText
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            color: Colors.text
                            font.family: Options.font.family
                            font.bold: true
                            font.pixelSize: 18
                            text: "Do Not Disturb" 
                        }

                        Text {
                            id: dndSubText
                            color: Colors.subtext0
                            font.family: Options.font.family
                            font.bold: false
                            font.pixelSize: 12
                            text: "Notifications are silent" 
                        }
                    }

                    ToggleSwitch {
                        id: dndSwitch
                        backColor: Colors.lavender
                        anchors {
                            verticalCenter: dndIconRect.verticalCenter
                            rightMargin: 12
                            right: parent.right
                        }
                        checked: NetworkService.wifiEnabled
                        onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
                    }
                }
            }
        }
    }
}
