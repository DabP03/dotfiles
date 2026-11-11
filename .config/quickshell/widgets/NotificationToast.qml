import QtQuick
import Quickshell.Services.Notifications

import "../config/"
import "../services/"
import "../widgets/"

// One toast: a NotificationCard in a bordered frame that hides itself after
// the notification's timeout. Hovering pauses the countdown; leaving restarts
// it. Clicking runs the default action (if any) and hides the toast, leaving
// the notification in the dash. The x on the card dismisses it completely.
Rectangle {
    id: root

    required property var notification // Notification

    readonly property bool alive: notification !== null && notification !== undefined
    readonly property bool critical: alive && notification.urgency === NotificationUrgency.Critical

    implicitHeight: card.implicitHeight + Options.borderWidth * 2 + 2
    radius: Options.radius
    color: Colors.base
    border.width: Options.borderWidth
    border.color: critical ? Colors.red : Colors.peach

    HoverHandler {
        id: hover
        onHoveredChanged: NotificationService.setToastHovered(root.notification, hover.hovered)
    }

    // Delegates only exist on the focused monitor, so the countdown lives in
    // NotificationService. If focus moves while the toast is hovered, release
    // the pause when this delegate is torn down.
    Component.onDestruction: NotificationService.setToastHovered(root.notification, false)

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
