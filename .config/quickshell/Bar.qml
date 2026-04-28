import Quickshell

import QtQuick
import Quickshell.Wayland
import "root:/config/"
import "root:/services/"
import "root:/components/"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow

            readonly property bool monitorHasWindows: {
                const mon = Hyprland.monitors.values.find(m => m.name === modelData.name)
                if (!mon) return false
                const wsId = Hyprland.workspacesWindows[mon.id]
                const ws = Hyprland.workspaces.values.find(w => w.id === wsId)
                return !(ws !== undefined && ws.toplevels.values.length !== 0)
            }

            property var modelData
            screen: modelData
            implicitHeight: 50
            color: "transparent"

            margins {
                top: 8 * monitorHasWindows
                left: 8 * monitorHasWindows
                right: 8 * monitorHasWindows
            }

            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                implicitHeight: parent.height
                implicitWidth: parent.width
                color: Colors.base
                radius: Options.radius * monitorHasWindows
                bottomRightRadius: Options.barRightBottomRadius * monitorHasWindows

                border.color: Colors.peach
                border.width: Options.borderWidth

                Behavior on bottomRightRadius {
                    NumberAnimation {
                        duration: 180
                        easing.type: Options.easingTypeOut
                    }
                }

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Rectangle {
                    visible: !monitorHasWindows
                    color: Colors.base
                    implicitHeight: parent.height - 2
                    implicitWidth: parent.width
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                }

                // ClockComp {
                //     id: clock
                //     visible: {
                //         return Players.active != null
                //     }
                //     anchors.verticalCenter: parent.verticalCenter
                //     anchors.right: battery.left
                //     anchors.rightMargin: Options.margin.inner
                // }

                Tray {
                    id: tray

                    barDocked: panelWindow.monitorHasWindows
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: battery.left
                    anchors.rightMargin: Options.margin.inner
                    bar: panelWindow
                }

                PlayerComp {
                    id: player
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    barDocked: panelWindow.monitorHasWindows

                }

                Battery {
                    id: battery
                    barDocked: panelWindow.monitorHasWindows
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: audio.left
                    anchors.rightMargin: Options.margin.inner
                }

                AudioComp {
                    id: audio
                    barDocked: panelWindow.monitorHasWindows
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: network.left
                    anchors.rightMargin: Options.margin.inner
                }

                NetworkComp {
                    id: network
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: dash.left
                    anchors.rightMargin: Options.margin.inner
                }

                DashComp {
                    id: dash
                    barDocked: panelWindow.monitorHasWindows
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Options.margin.outer
                }

                Workspaces {
                    id: workspaces
                    screen: panelWindow.screen
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Options.margin.outer
                }

                ActiveWindow {
                    id: activeWindow
                    screen: panelWindow.screen
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: workspaces.right
                    anchors.leftMargin: Options.margin.outer
                    
                }
            }
        }
    }
}
