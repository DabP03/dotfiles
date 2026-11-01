pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon + notification-center state.
// Named NotificationService because Notification and NotificationServer are
// already types in Quickshell.Services.Notifications.
//
// Running this makes Quickshell own org.freedesktop.Notifications on the
// session bus, so any other daemon (mako, dunst, swaync...) must be stopped.
Singleton {
    id: root

    // Do not disturb: new notifications skip the toast popups (critical ones
    // still show). The dash list always shows everything.
    property bool dnd: false

    // Master switch for toast popups, and how long a toast stays when the
    // sender gave no timeout.
    property bool toastsEnabled: true
    property int defaultToastMs: 5000

    readonly property var tracked: server.trackedNotifications // ObjectModel<Notification>
    readonly property int count: tracked.values.length
    readonly property bool hasNotifications: count > 0

    // Newest first, as a plain array for a ScriptModel.
    readonly property var newestFirst: {
        const out = [];
        const v = tracked.values;
        for (let i = v.length - 1; i >= 0; i--)
            out.push(v[i]);
        return out;
    }

    function dismiss(n) {
        if (n)
            n.dismiss();
    }

    function dismissAll() {
        // copy first: dismissing changes the model while we iterate
        const copy = [];
        const v = tracked.values;
        for (let i = 0; i < v.length; i++)
            copy.push(v[i]);
        for (let i = 0; i < copy.length; i++)
            copy[i].dismiss();
    }

    // Actions that deserve a button: has a label and isn't the "default" action,
    // which is what clicking the notification itself should trigger.
    function visibleActions(n) {
        const out = [];
        if (!n)
            return out;
        for (let i = 0; i < n.actions.length; i++) {
            const a = n.actions[i];
            if (a.text && a.identifier !== "default")
                out.push(a);
        }
        return out;
    }

    function hasDefaultAction(n) {
        if (!n)
            return false;
        for (let i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === "default")
                return true;
        }
        return false;
    }

    function invokeDefault(n) {
        if (!n)
            return;
        for (let i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === "default") {
                n.actions[i].invoke();
                return;
            }
        }
    }

    // Bodies may contain markup even though we don't advertise support for it.
    // Strip tags and decode the common entities so PlainText rendering is clean.
    function stripMarkup(s) {
        return String(s ?? "")
            .replace(/<br\s*\/?>/gi, "\n")
            .replace(/<[^>]*>/g, "")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .replace(/&#39;|&apos;/g, "'")
            .replace(/&amp;/g, "&")
            .trim();
    }

    // ── toasts ──
    // Toasts are a subset of the tracked notifications, keyed by id. Hiding a
    // toast leaves the notification in the dash; dismissing removes both.
    property var toastIds: ({})

    readonly property var toasts: {
        const ids = toastIds;
        const out = [];
        for (const n of newestFirst) {
            if (ids[n.id])
                out.push(n);
        }
        return out;
    }
    readonly property bool hasToasts: toasts.length > 0

    function showToast(n) {
        const ids = Object.assign({}, toastIds);
        ids[n.id] = true;
        toastIds = ids;
    }

    function hideToast(n) {
        if (!n)
            return;
        const ids = Object.assign({}, toastIds);
        delete ids[n.id];
        toastIds = ids;
    }

    // Milliseconds before a toast hides itself; 0 = stay until acted on.
    function toastTimeout(n) {
        if (!n)
            return 0;
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        return n.expireTimeout > 0 ? n.expireTimeout * 1000 : defaultToastMs;
    }

    NotificationServer {
        id: server

        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        // Untracked notifications are discarded, so keep every one.
        onNotification: n => {
            n.tracked = true;

            // Notifications carried over from before a reload stay in the list
            // but don't pop up again.
            if (root.toastsEnabled && !n.lastGeneration
                    && (!root.dnd || n.urgency === NotificationUrgency.Critical))
                root.showToast(n);
        }
    }
}
