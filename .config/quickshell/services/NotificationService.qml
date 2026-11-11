pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

import "../config/"
import "../services/"

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

    // How many notifications the dash keeps. Past this the oldest are
    // dismissed (normal NotificationClosed behaviour) so a long session does
    // not accumulate images and objects without bound. Applied to
    // notifications carried over a reload as well as new ones.
    property int maxTracked: 50

    // Newest first, as a plain array for a ScriptModel.
    readonly property var newestFirst: {
        const out = [];
        const v = tracked.values;
        for (let i = v.length - 1; i >= 0; i--)
            out.push(v[i]);
        return out;
    }

    function dismiss(n) {
        if (!n)
            return;
        hideToast(n);
        n.dismiss();
    }

    function dismissAll() {
        // copy first: dismissing changes the model while we iterate
        const copy = [];
        const v = tracked.values;
        for (let i = 0; i < v.length; i++)
            copy.push(v[i]);
        for (let i = 0; i < copy.length; i++) {
            hideToast(copy[i]);
            copy[i].dismiss();
        }
    }

    // Drop the oldest notifications once the cap is exceeded. `tracked` keeps
    // insertion order, so the front of the array is the oldest.
    function enforceTrackedLimit() {
        const v = tracked.values;
        const excess = v.length - maxTracked;
        if (excess <= 0)
            return;

        const oldest = [];
        for (let i = 0; i < excess; i++)
            oldest.push(v[i]);
        for (let i = 0; i < oldest.length; i++) {
            hideToast(oldest[i]);
            oldest[i].dismiss();
        }
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

    // Expiry lives here rather than in the toast delegate. Delegates are only
    // built on the focused monitor, so a delegate-owned timer would restart
    // every time focus moves. id -> absolute deadline in ms, 0 = stay until
    // acted on.
    property var toastDeadlines: ({})
    // Remaining ms while the pointer is over a toast (id -> ms).
    property var toastHoverRemaining: ({})

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
        if (!n)
            return;
        const ids = Object.assign({}, toastIds);
        ids[n.id] = true;
        toastIds = ids;

        const deadlines = Object.assign({}, toastDeadlines);
        const ms = toastTimeout(n);
        deadlines[n.id] = ms > 0 ? Date.now() + ms : 0;
        toastDeadlines = deadlines;
    }

    function hideToast(n) {
        if (n)
            hideToastId(n.id);
    }

    function hideToastId(id) {
        if (!toastIds[id])
            return;

        const ids = Object.assign({}, toastIds);
        delete ids[id];
        toastIds = ids;

        const deadlines = Object.assign({}, toastDeadlines);
        delete deadlines[id];
        toastDeadlines = deadlines;

        const hovering = Object.assign({}, toastHoverRemaining);
        delete hovering[id];
        toastHoverRemaining = hovering;
    }

    // Hovering pauses the countdown: keep the remaining time, not the deadline,
    // so leaving the toast doesn't make it expire immediately.
    function setToastHovered(n, hovered) {
        if (!n || !toastIds[n.id])
            return;

        const deadlines = Object.assign({}, toastDeadlines);
        const hovering = Object.assign({}, toastHoverRemaining);

        if (hovered) {
            if (deadlines[n.id] > 0 && hovering[n.id] === undefined)
                hovering[n.id] = Math.max(0, deadlines[n.id] - Date.now());
        } else if (hovering[n.id] !== undefined) {
            if (deadlines[n.id] > 0)
                deadlines[n.id] = Date.now() + hovering[n.id];
            delete hovering[n.id];
        } else {
            return;
        }

        toastDeadlines = deadlines;
        toastHoverRemaining = hovering;
    }

    function expireToasts() {
        const now = Date.now();
        const ids = toastIds;
        const hovering = toastHoverRemaining;
        let expired = null;

        for (const id in ids) {
            if (hovering[id] !== undefined)
                continue;
            const deadline = toastDeadlines[id];
            if (deadline > 0 && now >= deadline)
                (expired || (expired = [])).push(id);
        }

        if (!expired)
            return;
        for (const id of expired)
            hideToastId(id);
    }

    Timer {
        interval: 250
        repeat: true
        running: root.hasToasts
        onTriggered: root.expireToasts()
    }

    // Milliseconds before a toast hides itself; 0 = stay until acted on.
    // Notification.expireTimeout is already in milliseconds (notification spec).
    function toastTimeout(n) {
        if (!n)
            return 0;
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        return n.expireTimeout > 0 ? n.expireTimeout : defaultToastMs;
    }

    // ── sound ──
    // Chime when a notification arrives. paplay is spawned asynchronously, so
    // a long file never blocks the shell.
    property int lastSoundMs: 0

    // The sender may name its own file in the hints; that wins over the theme
    // sound, and critical notifications get the error chime.
    function soundFile(n) {
        const hint = n?.hints?.["sound-file"];
        if (hint)
            return String(hint);
        return n?.urgency === NotificationUrgency.Critical
            ? Options.sound.critical
            : Options.sound.normal;
    }

    function playSound(n) {
        if (!Options.sound.enabled)
            return;
        if (Audio.muted)
            return;
        const now = Date.now();
        if (now - lastSoundMs < Options.sound.cooldown)
            return; // burst: one chime covers the whole batch
        lastSoundMs = now;
        soundProc.file = soundFile(n);
        soundProc.running = true;
    }

    Process {
        id: soundProc
        property string file: Options.sound.normal
        command: ["paplay", file]
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
            // Also trims notifications carried over from before a reload.
            root.enforceTrackedLimit();

            // Notifications carried over from before a reload stay in the list
            // but don't pop up or chime again.
            if (n.lastGeneration)
                return;

            // Toasts and chimes share the DND gate: quiet while DND, except
            // for critical notifications. Chimes stay independent of
            // toastsEnabled, so hiding popups alone doesn't silence them.
            const audible = !root.dnd || n.urgency === NotificationUrgency.Critical;

            if (root.toastsEnabled && audible)
                root.showToast(n);

            if (audible)
                root.playSound(n);
        }
    }
}
