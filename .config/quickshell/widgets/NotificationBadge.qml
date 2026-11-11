import QtQuick

import "../config/"
import "../services/"

// Small dot for the corner of a bar button. Shown while the notification list
// is not empty; grey while Do Not Disturb is on. The ring uses the bar color
// so the dot stays readable on top of a colored button.
Rectangle {
    id: root

    property real size: 12
    readonly property bool active: NotificationService.hasNotifications

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: NotificationService.dnd ? Colors.subtext0 : Colors.red
    border.width: 2
    border.color: Colors.base

    scale: active ? 1 : 0
    visible: scale > 0

    Behavior on scale {
        NumberAnimation {
            duration: Motion.pop
            easing.type: Motion.arrive
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Motion.state
            easing.type: Motion.arrive
        }
    }
}
