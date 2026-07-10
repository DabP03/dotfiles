pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQml

import "root:/config/"

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    readonly property var playbackStates: list.map(p => p.playbackState)

    property MprisPlayer lastConfirmedPlaying: null

    // Track when each player last *started* playing so that, when several
    // players are playing at once, we can prefer the most recently started one
    // (e.g. play Spotify after Strawberry -> show Spotify) instead of always
    // picking the first player in Mpris.players.values. Records a transition
    // from not-playing to playing, so pausing one and starting another (or
    // resuming) updates its timestamp.
    property var startTimes: ({})
    property var prevStates: ({})
    property string lastStateKey: ""
    property int reconputeToken: 0

    // Snapshot the playback states so we can detect transitions even if the
    // MprisPlayer.playbackState bindings don't push updates on their own.
    function snapshotKey() {
        return list.map(p => normId(getIdentity(p)) + "=" + p.playbackState).join(",")
    }

    function trackAll() {
        const ids = new Set(list.map(p => normId(getIdentity(p))))
        for (const id of Object.keys(prevStates)) {
            if (!ids.has(id)) {
                delete prevStates[id]
                delete startTimes[id]
            }
        }
        for (const p of list) {
            const id = normId(getIdentity(p))
            const prev = prevStates[id]
            const now = p.playbackState
            if (prev !== MprisPlaybackState.Playing && now === MprisPlaybackState.Playing) {
                startTimes[id] = Date.now()
            }
            prevStates[id] = now
        }
    }

    readonly property MprisPlayer candidatePlaying: {
        reconputeToken
        playbackStates
        let best = null
        let bestTime = -1
        for (const p of list) {
            if (shownPlayers.includes(normId(getIdentity(p))) &&
            p.playbackState === MprisPlaybackState.Playing) {
                const t = startTimes[normId(getIdentity(p))] ?? 0
                if (t >= bestTime) {
                    best = p
                    bestTime = t
                }
            }
        }
        return best
    }

    // Only update lastConfirmedPlaying when something IS playing (not when it drops)
    onCandidatePlayingChanged: {
        if (candidatePlaying) lastConfirmedPlaying = candidatePlaying
    }

    // Poll the playback states: when any differ from the last snapshot, record
    // transitions and bump the token so candidatePlaying re-evaluates.
    Timer {
        interval: 200
        repeat: true
        running: root.list.length > 0
        onTriggered: {
            const key = root.snapshotKey()
            if (key !== root.lastStateKey) {
                root.lastStateKey = key
                root.trackAll()
                root.reconputeToken = root.reconputeToken + 1
            }
        }
    }

    readonly property MprisPlayer active: {
        playbackStates

        if (props.manualActive?.playbackState === MprisPlaybackState.Playing)
        return props.manualActive

        if (candidatePlaying) return candidatePlaying

        // Hold the last known playing player during the brief gap between tracks
        if (lastConfirmedPlaying) return lastConfirmedPlaying

        if (props.manualActive) return props.manualActive

        return list.find(p => normId(getIdentity(p)) === normId(Options.defaultPlayer))
        ?? list.find(p => shownPlayers.includes(normId(getIdentity(p))))
        ?? null
    }
    readonly property real volume: active.volume
    property list<var> shownPlayers: [
        "spotify",
        "tidal-hifi",
        "strawberry"
    ]
    readonly property string songInfo: {
        if (!active || !active.trackTitle) return ""
        if (active.trackArtist)
        return qsTr("%1 - %2").arg(active.trackTitle).arg(active.trackArtist)
        return active.trackTitle
    }
    property alias manualActive: props.manualActive

    // Icon glyph + display name per player identity. Add entries here as needed;
    // falls back to a generic music icon / the raw identity string.
    readonly property var playerIcons: ({
        "spotify": "spotify",
        "tidal-hifi": "tidal-hifi",
        "strawberry": "org.strawberrymusicplayer.strawberry"
    })
    readonly property var playerNames: ({
        "spotify": "Spotify",
        "tidal-hifi": "Tidal",
        "strawberry": "Strawberry"
    })

    function getSourceIcon(identity: string): string {
        return playerIcons[normId(identity)] ?? ""
    }

    function getSourceName(identity: string): string {
        return playerNames[normId(identity)] ?? identity
    }

    function formatTime(seconds: real): string {
        if (!seconds || seconds < 0) return "0:00"
        const total = Math.floor(seconds)
        const mins = Math.floor(total / 60)
        const secs = total % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    function getIdentity(player: MprisPlayer): string {
        return player.identity;
    }

    // Normalize an identity to a stable lowercase key so lookups are
    // case-insensitive. MPRIS exposes e.g. "Spotify" but players may also
    // report "spotify"; we don't want that to break shownPlayers/startTimes.
    function normId(id: string): string {
        return String(id).toLowerCase()
    }

    function getActive(prop: string): string {
        const active = root.active;
        return active ? active[prop] ?? "Invalid property" : "No active player";
    }

    function changeVolume(amount: real): void {
        const active = root.active;
        if (active.canControl && active.volumeSupported) {
            let new_volume = active.volume + amount;
            active.volume = new_volume > 1.0 ? 1.0 : new_volume < 0.0 ? 0.0 : new_volume
        }
    }

    function shuffle(): void {
        const active = root.active;
        if (active.shuffleSupported) {
            active.shuffle = !active.shuffle;
        }
    }

    function loop(): void {
        const active = root.active;
        if (active.loopSupported) {
            switch (active.loopState) {
                case MprisLoopState.Playlist:
                    active.loopState = MprisLoopState.Track;
                    break;
                case MprisLoopState.Track:
                    active.loopState = MprisLoopState.None;
                    break;
                case MprisLoopState.None:
                    active.loopState = MprisLoopState.Playlist;
                    break;
            }
        }
    }

    function list(): string {
        return root.list.map(p => root.getIdentity(p)).join("\n");
    }

    function play(): void {
        const active = root.active;
        if (active?.canPlay)
        active.play();
    }

    function pause(): void {
        const active = root.active;
        if (active?.canPause)
        active.pause();
    }

    function playPause(): void {
        const active = root.active;
        if (active?.canTogglePlaying)
        active.togglePlaying();
    }

    function previous(): void {
        const active = root.active;
        if (active?.canGoPrevious)
        active.previous();
    }

    function next(): void {
        const active = root.active;
        if (active?.canGoNext)
        active.next();
    }

    function stop(): void {
        root.active?.stop();
    }

    function getPlaybackIcon(player: MprisPlayer): string {
        if (player.canPlay && player.canPause && player.canControl) {
            switch (player.playbackState) {
                case MprisPlaybackState.Playing:
                return ""
                break;
                case MprisPlaybackState.Paused:
                case MprisPlaybackState.Stopped:
                return ""
                break;
            }
        }
    }

    Connections {
        target: active

        function onPostTrackChanged() {
            if (active.trackArtist != "" && active.trackTitle != "") {
                songInfo = qsTr("%1 - %2").arg(active.trackTitle).arg(active.trackArtist)
            }
            positionTimer.active()
        }
    }

    // MPRIS players rarely push position updates on their own, so nudge it
    // along manually while something is playing (see Quickshell docs for
    // MprisPlayer.position). Consumers like a seek slider bind to
    // Players.active.position and rely on this to stay current.
    Timer {
        id: positionTimer
        running: root.active != null && root.active.playbackState == MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: root.active.positionChanged()
    }

    Connections {
    target: Mpris
    function onPlayersChanged() {
        root.lastStateKey = root.snapshotKey()
        root.trackAll()
        root.reconputeToken = root.reconputeToken + 1
        const playing = root.list.find(p =>
            root.shownPlayers.includes(root.normId(root.getIdentity(p))) &&
            p.playbackState === MprisPlaybackState.Playing
        )
        // Clear manual pick if something else started playing
        if (playing && playing !== props.manualActive)
            props.manualActive = null
    }
}


    PersistentProperties {
        id: props

        property MprisPlayer manualActive

        reloadableId: "players"
    }

}
