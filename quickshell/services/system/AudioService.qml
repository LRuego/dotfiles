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

    // --- NODE LISTS (volume menu) ---
    // Grouped by PipeWire media.class, like pavucontrol's tabs.
    function mediaClass(node) {
        return node?.properties?.["media.class"] ?? ""
    }

    readonly property var _audioNodes: Pipewire.nodes.values.filter(n => n && n.audio)
    readonly property var outputs:   _audioNodes.filter(n => !n.isStream && root.mediaClass(n).startsWith("Audio/Sink"))
    readonly property var inputs:    _audioNodes.filter(n => !n.isStream && root.mediaClass(n).startsWith("Audio/Source"))
    readonly property var playback:  _audioNodes.filter(n => n.isStream && root.mediaClass(n) === "Stream/Output/Audio")
    // Level-meter streams (ours and pavucontrol's) are capture streams too; they aren't apps recording.
    readonly property var recording: _audioNodes.filter(n => n.isStream && root.mediaClass(n) === "Stream/Input/Audio"
                                                         && n.properties["stream.monitor"] !== "true")

    // Device: its description. Stream: the app's name.
    function nodeTitle(node) {
        if (!node) return ""
        if (node.isStream) return node.properties["application.name"] || node.description || node.name
        return node.description || node.nickname || node.name
    }

    // Stream: what it's playing/recording (e.g. a tab title). Devices have none.
    function nodeDetail(node) {
        return node?.isStream ? (node.properties["media.name"] ?? "") : ""
    }

    // Stream: the app's icon, from its desktop entry when one matches (the stream's own icon name can be wrong,
    // e.g. Helium says "helium" but its icon is "helium-browser"), else the name the stream gives. "" if none.
    function appIconName(node) {
        let p = node?.properties ?? {}
        let entry = DesktopEntries.heuristicLookup(p["application.process.binary"] || p["application.name"] || "")
        return entry?.icon || p["application.icon-name"] || p["application.process.binary"] || ""
    }

    function isDefault(node) {
        return node !== null && (node === root.sink || node === root.source)
    }

    function setDefault(node) {
        if (!node) return
        if (node.isSink) Pipewire.preferredDefaultAudioSink = node
        else Pipewire.preferredDefaultAudioSource = node
    }

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
