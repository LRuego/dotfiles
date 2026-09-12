// services/system/AudioService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: root

    // --- PIPEWIRE OBJECTS ---
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    // --- TRACKER ---
    // Track the full node graph, not just the current sink/source: Quickshell's
    // PipeWire default-node resolution only stays live for nodes it has bound,
    // so tracking just [sink, source] leaves default changes (e.g. a bluetooth
    // headset connecting mid-session) stuck on the old node until the whole
    // quickshell process restarts.
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    // --- PUBLIC API ---
    readonly property int volume: Math.round((root.sink?.audio?.volume ?? 0) * 100)
    readonly property bool isMuted: root.sink?.audio?.muted ?? true

    readonly property int micVolume: Math.round((root.source?.audio?.volume ?? 0) * 100)
    readonly property bool isMicMuted: root.source?.audio?.muted ?? true

    // --- ACTIONS ---
    function toggleMute() {
        if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
    }

    function toggleMic() {
        if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted
    }

    function adjustVolume(isUp) {
        if (!root.sink?.audio) return
        let current = root.sink.audio.volume
        let step = 0.10 
        let next = isUp ? Math.min(1.0, current + step) : Math.max(0.0, current - step)
        root.sink.audio.volume = next
    }

    function adjustMicVolume(isUp) {
        if (!root.source?.audio) return
        let current = root.source.audio.volume
        let step = 0.10 
        let next = isUp ? Math.min(1.0, current + step) : Math.max(0.0, current - step)
        root.source.audio.volume = next
    }
}
