pragma Singleton

import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    readonly property Monitor monitor: Monitor {}
    readonly property Inhibitor inhibitor:  Inhibitor {}

    component Monitor: QtObject {
        readonly property bool isIdle: idleMonitor.isIdle
        readonly property real timeout: idleMonitor.timeout
        readonly property bool enabled: idleMonitor.enabled
    }

    component Inhibitor: QtObject {
        readonly property bool enabled: idleInhibitor.enabled
        function toggle(): void {
            idleInhibitor.enabled = !idleInhibitor.enabled
        }
    }

    function setWindow(window: QtObject): void {
        idleInhibitor.window = window
    }

    IdleMonitor {
        id: idleMonitor
        timeout: 300
        enabled: false
    }

    IdleInhibitor {
        id: idleInhibitor
        window: null
        enabled: false
    }

}
