import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    color: "transparent"
    implicitHeight: parent.height - 16
    implicitWidth: {
        let width = clockText.width + 20;
        Options.width.clock = width;
        return width;
    } 
    radius: 8

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (event) => {
            if (dynamicLoader.active) {
                dynamicLoader.active = false  // Hide/destroy
            } else {
                dynamicLoader.active = true   // Create/show
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: mouseArea.containsMouse ? Qt.lighter(Colors.maroon, 1.1) : Colors.maroon
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                        easing.type: Easing.Linear
                    }
                }
            }
            GradientStop {
                position: 1.0
                color: mouseArea.containsMouse ? Qt.lighter(Colors.mauve, 1.1) : Colors.mauve
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                        easing.type: Easing.Linear
                    }
                }
            }
        }    

        Text {
            id: clockText
            font.family: Options.font.family
            font.pixelSize: Options.font.size
            font.bold: true
            color: Colors.base
            text: Time.time
            anchors.centerIn: parent
        }

        Loader {
            id: dynamicLoader
            active: false  // Starts hidden
            sourceComponent: PanelWindow {
                id: calendarPanel
                implicitHeight: 304
                implicitWidth: 304

                exclusionMode: ExclusionMode.Normal
                anchors {
                    top: true
                }
                margins {
                    top: -2
                }
                color: "transparent"

                Rectangle {
                    id: calendar
                    anchors.fill: parent
                    color: Colors.base
                    radius: Options.radius
                    topLeftRadius: 0
                    topRightRadius: 0
                    border.color: Colors.peach
                    border.width: Options.borderWidth
                    implicitHeight: calendarPanel.implicitHeight
                    implicitWidth: calendarPanel.implicitWidth

                    // Behavior on opacity {
                    //     NumberAnimation {
                    //         duration: 200
                    //         easing.type: Options.easingTypeOut
                    //     }
                    // }

                    Rectangle {
                        id: topBorder
                        width: parent.width - Options.borderWidth * 2
                        height: Options.borderWidth
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Colors.base
                    }

                    MouseArea {
                        id: mouseAreaCalendar
                        anchors.fill: parent
                        hoverEnabled: true
                        onExited: {
                            if (!mouseAreaCalendar.containsMouse) {
                                dynamicLoader.active = false
                            }
                        }
                    }
                    Calendar {
                        anchors.margins: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
