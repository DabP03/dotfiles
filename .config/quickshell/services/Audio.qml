pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0


    property var sinks: Pipewire.nodes.values.filter(node => node.isSink && node.isStream)

    // sinks grouped by application, e.g. { appName: "Firefox", nodes: [tab1, tab2, ...] }.
    // Apps with a single stream stay as a flat entry; apps with multiple streams
    // (like a browser with several tabs playing audio) become a tree.
    property var groupedSinks: {
        const groups = {}
        const order = []

        for (const node of sinks) {
            const appName = node.properties["application.name"]
                ?? node.nickname
                ?? node.name
                ?? "Unknown"

            if (!groups[appName]) {
                groups[appName] = { appName: appName, nodes: [] }
                order.push(appName)
            }

            groups[appName].nodes.push(node)
        }

        return order.map(name => groups[name])
    }

    function setVolume(volume: real, node: PwNode): void {
        if (node == undefined) {
            node = sink
        }

        if (node?.ready && node?.audio) {
            node.audio.muted = false;
            node.audio.volume = volume;
        }
    }

    function mute(node: PwNode): void {
        if (node == undefined) {
            node = sink
        }

        if (node?.ready && node?.audio) {
            if (node?.audio?.muted) node.audio.muted = false
            else node.audio.muted = true
        }

    }

    function increment(node: PwNode): void {
        if (node == undefined) {
            node = sink
        }

        if (node?.ready && node?.audio) {
            node.audio.muted = false;
            node.audio.volume += 0.01;
        }
    }

    function decrement(node: PwNode): void {
        if (node == undefined) {
            node = sink
        }

        if (node?.ready && node?.audio) {
            node.audio.muted = false;
            node.audio.volume -= 0.01;
        }
    }

    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }

    PwObjectTracker {
        id: sourceTracker
        objects: [Pipewire.defaultAudioSource]
    }

    Connections {
		target: Pipewire.defaultAudioSink?.audio
	}
}
