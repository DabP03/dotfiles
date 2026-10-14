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

        onClicked: (event) => {
                popup.visible = !popup.visible  // Hide/destroy
                grab.active = !grab.active
        }
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
            text: Time.time
        }

        PopupWindow {
            id: popup
            visible: false
            implicitWidth: calendarPanel.implicitWidth + 24
            implicitHeight: 400
            anchor.window: bar
            anchor.rect.x: parentWindow.width - popup.implicitWidth
            anchor.rect.y: parentWindow.height - 2
            anchor.adjustment: PopupAdjustment.None
            color: "transparent"

            HyprlandFocusGrab {
                id: grab
                windows: [ popup ]
                active: false
                onCleared: () => {
                    popup.visible = false
                }
            }

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
                        bottom: parent.bottom
                        left: parent.left
                        bottomMargin: 12
                        leftMargin: 12
                    }
                    color: Colors.mantle
                    radius: Options.radius
                    implicitHeight: 304
                    implicitWidth: 304

                    // Behavior on opacity {
                    //     NumberAnimation {
                    //         duration: 200
                    //         easing.type: Options.easingTypeOut
                    //     }
                    // }

                    Calendar {
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
                        topMargin: 6
                    }
                    color: Colors.mantle
                    radius: Options.radius
                    implicitWidth: power.implicitWidth + 28
                    implicitHeight: power.implicitWidth + 28

                    Text {
                        id: monthText
                        color: Colors.text
                        font.family: Options.font.family
                        font.bold: true
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 14
                        }
                        text: Time.date
                    }

                    Text {
                        color: Colors.text
                        font.family: Options.font.family
                        font.bold: true
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: monthText.bottom
                        }
                        text: Time.year
                    }
                }

                Rectangle {
                    id: buttonsPanel
                    anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin: 12
                        topMargin: 6
                    }
                    color: Colors.mantle
                    radius: Options.radius
                    implicitWidth: calendarPanel.implicitWidth - datePanel.implicitWidth - 12
                    implicitHeight: power.implicitWidth + 28

                    RowLayout {
                        id: column
                        spacing: 8
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
                            fontSize: 20
                            buttonText: ""
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
                            fontSize: 20
                            buttonText: ""
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
                            fontSize: 20
                            buttonText: ""
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
                            buttonText: ""
                            fontSize: 20
                            onClick: () => {
                                process.exec(["systemctl", "poweroff"])
                            }
                        }
                    }
                }
            }
        }
    }
}
