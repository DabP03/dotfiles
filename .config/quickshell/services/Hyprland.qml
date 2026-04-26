pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    readonly property var toplevels: Hyprland.toplevels
    readonly property var workspaces: Hyprland.workspaces
    readonly property var monitors: Hyprland.monitors
    readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1
    property list<int> workspacesWindows: []
    readonly property bool hasVisibleToplevels: {
        let ret = true
        for (let i = 0; i < workspacesWindows.length; i++) {
            const wsId = workspacesWindows[i]
            const ws = workspaces.values.find(w => w.id === wsId)
            if (ws && ws.toplevels.values.length !== 0) {
                ret = false
                break
            }
        }
        return ret
    }

    readonly property var filledWsIds: {
        return workspaces.values.map(ws => ws.id)
    }


    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name.endsWith("v2"))
                return;

            getWindowsNum.running = true;
            if (event.name.includes("mon"))
                Hyprland.refreshMonitors();
            else if (event.name.includes("workspace"))
                Hyprland.refreshWorkspaces();
            else
                Hyprland.refreshToplevels();
        }
    }

    Process {
        id: getWindowsNum
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const out = JSON.parse(this.text);
                let newMap = []
                for (let i = 0; i < out.length; i++) {
                    newMap[out[i].id] = out[i].activeWorkspace.id  // monitorId → wsId
                }
                root.workspacesWindows = newMap  // triggers reactive update
            }
        }
    }
}
