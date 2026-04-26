import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    required property bool barDocked
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

        function handleClicked(event) {
            menu.shown = !menu.shown // Toggle visibility
        }

        onClicked: (event) => {
            if (dynamicLoader.active) {
                dynamicLoader.active = false  // Hide/destroy
                Options.barRightBottomRadius = 16.0
            } else {
                dynamicLoader.active = true   // Create/show
                Options.barRightBottomRadius = 0.0
            }

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
            text: ""
        }

        Loader {
            id: dynamicLoader
            active: false  // Starts hidden
            sourceComponent: Component {
                PanelWindow {
                    id: menuPanel
                    anchors {
                        top: true
                        right: true
                    }
                    implicitHeight: root.implicitHeight * 4 + 25
                    implicitWidth: logout.implicitWidth + 28
                    margins {
                        top: -2
                        right: Options.margin.inner * root.barDocked
                    }
                    color: "transparent"

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 200
                            easing.type: Options.easingTypeOut
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
                        implicitHeight: menuPanel.implicitHeight
                        implicitWidth: menuPanel.implicitWidth

                        Behavior on implicitHeight {
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

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onExited: {
                                if (!lock.containsMouse &&
                                !power.containsMouse &&
                                !logout.containsMouse &&
                                !restart.containsMouse) {
                                    dynamicLoader.active = false
                                    Options.barRightBottomRadius = 16.0
                                }
                            }
                        }

                        Process {
                            id: process
                        }

                        ColumnLayout {
                            id: column
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                // verticalCenter: parent.verticalCenter
                                top: parent.top
                            }
                            spacing: 4

                            StyledButton {
                                id: power
                                implicitWidth: (logout.textWidth + 25)
                                implicitHeight: root.implicitHeight
                                radius: Options.buttonRadius
                                buttonColor: Colors.red
                                buttonTextColor: Colors.base
                                buttonText: ""
                                onClick: () => {
                                    process.exec(["systemctl", "poweroff"])
                                }
                            }

                            StyledButton {
                                id: restart
                                implicitWidth: (logout.textWidth + 25)
                                implicitHeight: root.implicitHeight
                                radius: Options.buttonRadius
                                buttonColor: Colors.yellow
                                buttonTextColor: Colors.base
                                buttonText: ""
                                onClick: () => {
                                    process.exec(["systemctl", "reboot"])
                                }
                            }

                            StyledButton {
                                id: logout
                                implicitWidth: (textWidth + 25)
                                implicitHeight: root.implicitHeight
                                radius: Options.buttonRadius
                                buttonColor: Colors.green
                                buttonTextColor: Colors.base
                                buttonText: ""
                                onClick: () => {
                                    process.exec(["systemctl", "exit"])
                                }
                            }
                            StyledButton {

                                id: lock
                                implicitWidth: (logout.textWidth + 25)
                                implicitHeight: root.implicitHeight
                                radius: Options.buttonRadius
                                buttonColor: Colors.blue
                                buttonTextColor: Colors.base
                                buttonText: ""
                                onClick: () => {
                                    process.exec(["hyprlock"])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
