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

    readonly property MprisPlayer candidatePlaying: {
        playbackStates
        return list.find(p =>
        shownPlayers.includes(getIdentity(p)) &&
        p.playbackState === MprisPlaybackState.Playing
    ) ?? null
    }

    // Only update lastConfirmedPlaying when something IS playing (not when it drops)
    onCandidatePlayingChanged: {
        if (candidatePlaying) lastConfirmedPlaying = candidatePlaying
    }

    readonly property MprisPlayer active: {
        playbackStates

        if (props.manualActive?.playbackState === MprisPlaybackState.Playing)
        return props.manualActive

        if (candidatePlaying) return candidatePlaying

        // Hold the last known playing player during the brief gap between tracks
        if (lastConfirmedPlaying) return lastConfirmedPlaying

        if (props.manualActive) return props.manualActive

        return list.find(p => getIdentity(p) === Options.defaultPlayer)
        ?? list.find(p => shownPlayers.includes(getIdentity(p)))
        ?? null
    }
    readonly property real volume: active.volume
    property list<var> shownPlayers: [
        "Spotify",
        "tidal-hifi",
        "Strawberry"
    ]
    readonly property string songInfo: {
        if (!active || !active.trackTitle) return ""
        if (active.trackArtist)
        return qsTr("%1 - %2").arg(active.trackTitle).arg(active.trackArtist)
        return active.trackTitle
    }
    property alias manualActive: props.manualActive

    function getIdentity(player: MprisPlayer): string {
        return player.identity;
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
        }
    }

    Connections {
    target: Mpris
    function onPlayersChanged() {
        const playing = root.list.find(p =>
            root.shownPlayers.includes(root.getIdentity(p)) &&
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
