import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// Toast popups. Declare once in shell.qml:  NotificationToasts {}
//
// One transparent overlay window per screen, only visible on the focused
// monitor and only while there are toasts. The window spans the screen's full
// height and its input region is limited to the toast stack, so the empty
// part never blocks clicks and the window never has to resize.
Variants {
    id: root

    // Space above the first toast: bar height plus a gap.
    property real topOffset: 54
    property real toastWidth: 380
    property real rightMargin: 8

    model: Quickshell.screens

    delegate: PanelWindow {
        id: win

        required property var modelData

        readonly property string focusedName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""

        screen: modelData
        visible: NotificationService.hasToasts
            && (focusedName === "" || focusedName === modelData.name)

        color: "transparent"
        anchors {
            top: true
            bottom: true
            right: true
        }
        implicitWidth: root.toastWidth + root.rightMargin
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-toasts"

        // Only the toast stack takes input.
        mask: Region { item: list }

        ListView {
            id: list
            anchors {
                top: parent.top
                topMargin: root.topOffset
                right: parent.right
                rightMargin: root.rightMargin
            }
            width: root.toastWidth
            height: Math.min(contentHeight, win.height - root.topOffset - 12)
            spacing: 8
            interactive: false

            model: ScriptModel {
                values: NotificationService.toasts
            }

            delegate: NotificationToast {
                required property var modelData
                width: ListView.view.width
                height: implicitHeight
                notification: modelData
            }

            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 150
                    }
                    NumberAnimation {
                        property: "x"
                        from: 40
                        to: 0
                        duration: 180
                        easing.type: Options.easingTypeOut
                    }
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 120
                }
            }

            displaced: Transition {
                NumberAnimation {
                    property: "y"
                    duration: 150
                    easing.type: Options.easingTypeOut
                }
            }
        }
    }
}
