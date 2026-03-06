pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../core"

Item {
    id: root

    // --- PIPEWIRE OBJECTS ---
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    // --- TRACKER ---
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // --- PUBLIC API ---
    readonly property int volume: Math.round((root.sink?.audio?.volume ?? 0) * 100)
    readonly property bool isMuted: root.sink?.audio?.muted ?? true

    readonly property string icon: {
        if (isMuted) return Assets.volumeMute
        if (volume >= 60) return Assets.volumeUp
        if (volume >= 30) return Assets.volumeDown
        return Assets.volume
    }

    readonly property color speakerColor: isMuted ? Theme.urgent : Theme.text

    readonly property int micVolume: Math.round((root.source?.audio?.volume ?? 0) * 100)
    readonly property bool isMicMuted: root.source?.audio?.muted ?? true
    readonly property string micIcon: isMicMuted ? Assets.microphoneMute : Assets.microphone
    readonly property color micColor: isMicMuted ? Theme.urgent : (isMicActive ? Theme.warning : Theme.text)

    // --- RECORDING DETECTION (Via privacy_dots.sh) ---
    property bool micActiveState: false

    Process {
        id: micProcess
        // We run the script in a loop because it's currently built to output once and exit.
        command: [Qt.resolvedUrl("../scripts/privacy_dots.sh")]
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    const json = JSON.parse(data)
                    root.micActiveState = json.class && json.class.includes("mic-on")
                } catch (e) {
                    root.micActiveState = false
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: micProcess.running = true
    }

    readonly property bool isMicActive: micActiveState

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
