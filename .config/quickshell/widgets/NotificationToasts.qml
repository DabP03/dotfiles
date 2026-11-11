import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../config/"
import "../services/"
import "../widgets/"

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

            // Only the focused monitor builds delegates. The other screens keep
            // this list empty, so a toast costs one card tree instead of one per
            // screen. Toast expiry lives in NotificationService, not in the
            // delegate, so moving focus doesn't restart the countdown.
            model: ScriptModel {
                values: win.visible ? NotificationService.toasts : []
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
                        duration: Motion.fade
                        easing.type: Motion.leave
                    }
                    NumberAnimation {
                        property: "x"
                        from: 40
                        to: 0
                        duration: Motion.popIn
                        easing.type: Motion.arrive
                    }
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Motion.popOut
                    easing.type: Motion.leave
                }
            }

            displaced: Transition {
                NumberAnimation {
                    property: "y"
                    duration: Motion.slide
                    easing.type: Motion.arrive
                }
            }
        }
    }
}
