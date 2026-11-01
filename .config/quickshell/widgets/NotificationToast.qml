import QtQuick
import Quickshell.Services.Notifications

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// One toast: a NotificationCard in a bordered frame that hides itself after
// the notification's timeout. Hovering pauses the countdown; leaving restarts
// it. Clicking runs the default action (if any) and hides the toast, leaving
// the notification in the dash. The x on the card dismisses it completely.
Rectangle {
    id: root

    required property var notification // Notification

    readonly property bool alive: notification !== null && notification !== undefined
    readonly property bool critical: alive && notification.urgency === NotificationUrgency.Critical
    readonly property int timeoutMs: NotificationService.toastTimeout(notification)

    implicitHeight: card.implicitHeight + Options.borderWidth * 2
    radius: Options.radius
    color: Colors.base
    border.width: Options.borderWidth
    border.color: critical ? Colors.red : Colors.peach

    HoverHandler { id: hover }

    Timer {
        interval: root.timeoutMs
        running: root.alive && root.timeoutMs > 0 && !hover.hovered
        repeat: false
        onTriggered: NotificationService.hideToast(root.notification)
    }

    NotificationCard {
        id: card
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Options.borderWidth
        }
        color: "transparent"
        border.width: 0
        notification: root.notification
        onActivated: NotificationService.hideToast(root.notification)
    }
}
