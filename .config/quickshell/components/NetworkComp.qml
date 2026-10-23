import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Rectangle {
    id: root
    required property var bar
    color: "transparent"
    implicitHeight: parent.implicitHeight - 16
    implicitWidth: icon.implicitWidth + 25; 
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
        color: mouseArea1.containsMouse ? Qt.lighter(Colors.blue, 1.1) : Colors.blue

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut // Smooth easing curve
            }
        }

        Icon {
            id: icon
            color: Colors.base 
            font.pixelSize: Options.font.size
            font.family: Options.font.iconFamily
            font.bold: true
            anchors.centerIn: parent
            text: {
                if (NetworkService.activeKind == "wired") {
                    return "lan"
                } else if (NetworkService.activeKind == "wifi") {
                    return NetworkService.signalStrengthSymbol
                } else return "signal_wifi_off"
            } 
        }
        BarPopup {
            id: popup
            target: root
            bar: root.bar
            anchor.rect.x: root.bar.width - root.mapToItem(null, 0, 0).x - popup.implicitWidth / 2 - root.implicitWidth / 2
            implicitWidth: 425
            readonly property real maxHeight: 440
            readonly property real wantedHeight: 60                                                              // header: 8 + 52
            + (wiredPanel.visible ? 16 + 72 : 0)                            // wired panel
            + (NetworkService.hasWifi ? 16 + wifiHeading.implicitHeight + 8 + wifiList.contentHeight : 0)
            + 16                                                            // bottom padding
            implicitHeight: Math.min(maxHeight, wantedHeight)


            onVisibleChanged: {
                if (visible) {
                    NetworkService.acquireScan()
                } else {
                    NetworkService.releaseScan()
                    NetworkService.cancelPassword()
                }
            }
            Rectangle {
                id: playerMenu
                anchors.fill: parent
                color: Colors.base
                radius: Options.radius
                topLeftRadius: 0
                topRightRadius: 0
                bottomRightRadius: 0
                border.color: Colors.peach
                border.width: Options.borderWidth
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

                Rectangle {
                    id: iconRect
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 16
                        topMargin: 8
                    }
                    implicitWidth: 52
                    implicitHeight: 52
                    color: NetworkService.activeKind === "none" ? Colors.surface0
                    :  Colors.blue
                    radius: Options.radius

                    Icon { 
                        text: NetworkService.activeKind === "wired" ? "lan"
                        : NetworkService.activeKind === "wifi" ? NetworkService.signalStrengthSymbol 
                        : "signal_wifi_off" 
                        anchors {
                            centerIn: parent
                        }
                        color: Colors.base
                        font.pixelSize: 24
                    }

                }

                ColumnLayout {
                    id: headerLayout
                    anchors {
                        verticalCenter: iconRect.verticalCenter
                        left: iconRect.right
                        leftMargin: 16
                        right: wifiSwitch.left
                        rightMargin: 12
                    }

                    Text {
                        id: headerNetworkText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        color: Colors.text
                        font.family: Options.font.family
                        font.bold: true
                        font.pixelSize: 18
                        text: NetworkService.activeKind === "wired" ? "Wired connection"
                        : NetworkService.activeKind === "wifi" ? NetworkService.activeWifiNetwork.name 
                        : "Not connected" 
                    }

                    Text {
                        id: headerNetworkSubText
                        color: Colors.subtext0
                        font.family: Options.font.family
                        font.bold: false
                        font.pixelSize: 12
                        text: NetworkService.activeKind === "wired" ? "Ethernet" + " - " + NetworkService.wiredDevice.linkSpeed + "Mbit/s"
                        : NetworkService.activeKind === "wifi" ? "Wifi" + " - " + Math.floor(NetworkService.activeSignalStrength * 100) + "%"
                        : "Connect to a network" 
                    }
                }
                ToggleSwitch {
                    id: wifiSwitch
                    visible: NetworkService.wifiDevice !== null
                    anchors {
                        verticalCenter: iconRect.verticalCenter
                        right: parent.right
                        rightMargin: 42
                    }
                    checked: NetworkService.wifiEnabled
                    enabled: NetworkService.wifiHardwareEnabled
                    onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
                }

                Rectangle {
                    id: wiredPanel
                    visible: NetworkService.hasWired
                    anchors {
                        top: iconRect.bottom
                        horizontalCenter: parent.horizontalCenter
                        topMargin: visible ? 16 : 0
                    }

                    implicitHeight: visible ? 72 : 0
                    implicitWidth: parent.implicitWidth - 32
                    radius: Options.radius
                    color: Colors.mantle

                    Icon { 
                        id: wiredPanelIcon
                        text: "lan" 
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 16
                        }
                        color: Colors.subtext0
                        font.pixelSize: 24
                    }

                    ColumnLayout {
                        id: wiredPanelLayout
                        anchors {
                            verticalCenter: wiredPanelIcon.verticalCenter
                            left: wiredPanelIcon.right
                            leftMargin: 16
                        }
                        spacing: 4

                        Text {
                            id: wiredPanelText
                            color: Colors.text
                            font.family: Options.font.family
                            font.bold: true
                            font.pixelSize: 16
                            text: "Ethernet"
                        }

                        Text {
                            id: wiredPanelSubText
                            color: Colors.subtext0
                            font.family: Options.font.family
                            font.bold: false
                            font.pixelSize: 12
                            text: NetworkService.wiredDevice.name + " - " + NetworkService.wiredDevice.address
                        }
                    }

                    Rectangle {
                        id: wiredPanelIndicatorRect
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 16
                        }
                        implicitWidth: wiredIndicator.implicitWidth + 16
                        implicitHeight: wiredIndicator.implicitHeight + 16
                        radius: Options.radius / 2
                        color: NetworkService.wiredDevice.connected ? Colors.blue : Colors.surface1

                        Text {
                            id: wiredIndicator
                            anchors {
                                centerIn: parent
                            }
                            color: NetworkService.wiredDevice.connected ? Colors.base : Colors.text
                            font.family: Options.font.family
                            font.bold: true
                            font.pixelSize: 12
                            text: NetworkService.wiredDevice.connected ? "Link Up" : "Link Down"
                        }
                    }
                }

                Text {
                    id: wifiHeading
                    visible: NetworkService.hasWifi
                    anchors {
                        top: wiredPanel.bottom
                        left: parent.left
                        topMargin: 16
                        leftMargin: 16
                    }
                    color: Colors.subtext0
                    font.family: Options.font.family
                    font.bold: true
                    font.pixelSize: 16
                    text: "Wi-Fi Networks"
                }

                WifiNetworkList {
                    id: wifiList
                    visible: NetworkService.hasWifi
                    anchors {
                        top: wifiHeading.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        topMargin: 8
                        leftMargin: 16
                        rightMargin: 16
                        bottomMargin: 16
                    }
                }

            }

        }

    }
}
