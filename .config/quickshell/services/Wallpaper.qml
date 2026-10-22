pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

// Wallpaper service: awww draws the wallpaper, Quickshell only picks it.
// Start it with the bar by calling Wallpaper.restore() from Bar.qml.
Singleton {
    id: root

    // ---- config ----
    readonly property string dir: Quickshell.env("HOME") + "/.wallpapers"
    // how often the wallpaper changes to a random one (any change restarts the countdown)
    property int autoIntervalMs: 15 * 60 * 1000
    readonly property var transitionArgs: [
        "--transition-type", "random",
        "--transition-step", "60",
        "--transition-angle", "45",
        "--transition-duration", "6",
        "--transition-fps", "60"
    ]

    // ---- state ----
    property string current: ""
    readonly property alias model: folder

    // Set the wallpaper on all monitors (random transition) and remember it.
    function apply(path: string): void {
        if (!path)
            return;
        autoTimer.restart();
        root.current = path;
        // saved.current = path; // triggers adapterUpdated -> writeAdapter()
        run(path, transitionArgs);
    }

    // Pick a random wallpaper from ~/.wallpapers, never the current one if avoidable.
    function random(): void {
        const n = folder.count;
        if (n === 0)
            return;
        let i = Math.floor(Math.random() * n);
        if (n > 1 && folder.get(i, "filePath") === root.current)
            i = (i + 1) % n;
        apply(folder.get(i, "filePath"));
    }

    // // Re-apply the saved wallpaper without a transition (call once from Bar.qml).
    // function restore(): void {
    //     Quickshell.execDetached(["mkdir", "-p", Quickshell.stateDir]);
    //     if (!saved.current)
    //         return;
    //     root.current = saved.current;
    //     run(saved.current, ["--transition-type", "none"]);
    // }

    // Ask awww what is actually displayed (in case something else changed it).
    function refresh(): void {
        queryProc.running = true;
    }

    function indexOf(path: string): int {
        for (let i = 0; i < folder.count; i++) {
            if (folder.get(i, "filePath") === path)
                return i;
        }
        return 0;
    }

    function run(path, args) {
        applyProc.path = path;
        applyProc.args = args;
        applyProc.retried = false;
        applyProc.running = true;
    }

    // ---- automatic random change ----
    Timer {
        id: autoTimer
        interval: root.autoIntervalMs
        repeat: true
        running: true
        onTriggered: {
            root.random()
            console.log("Zmiana tapety")
        }
    }

    // ---- wallpaper files ----
    FolderListModel {
        id: folder
        folder: "file://" + root.dir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif"]
        caseSensitive: false
        showDirs: false
        sortField: FolderListModel.Name
    }

    // ---- awww ----
    Process {
        id: applyProc
        property string path: ""
        property var args: []
        property bool retried: false
        command: ["awww", "img", path].concat(args)
        onExited: (code, status) => {
            // Daemon not running yet (e.g. shell started before it): start it and retry once.
            if (code !== 0 && !retried) {
                retried = true;
                Quickshell.execDetached(["awww-daemon"]);
                retryTimer.start();
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 600
        onTriggered: applyProc.running = true
    }

    Process {
        id: queryProc
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                // e.g. "0: DP-1: 1920x1080, scale: 1, currently displaying: image: /path/a.jpg"
                const m = text.match(/image:\s*(.+)$/m);
                if (m)
                    root.current = m[1].trim();
            }
        }
    }

    // // ---- persistence ----
    // FileView {
    //     id: stateFile
    //     path: Quickshell.statePath("wallpaper.json")
    //     blockLoading: true
    //     printErrors: false
    //     onAdapterUpdated: writeAdapter()
    //
    //     JsonAdapter {
    //         id: saved
    //         property string current: ""
    //     }
    // }

    // ---- IPC: qs ipc call wallpaper <function> ----
    IpcHandler {
        target: "wallpaper"

        function random(): void {
            root.random();
        }
        function set(path: string): void {
            root.apply(path);
        }
    }
}
