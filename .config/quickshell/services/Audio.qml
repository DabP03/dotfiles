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

    readonly property PwNodeLinkTracker sinkLinkTracker: PwNodeLinkTracker {
        node: Pipewire.defaultAudioSink
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
