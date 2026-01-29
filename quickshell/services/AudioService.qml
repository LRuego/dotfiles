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
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // --- READINESS CHECKS ---
    readonly property bool sinkReady: sink?.bound ?? false
    readonly property bool sourceReady: source?.bound ?? false

    // --- PUBLIC API ---
    // 1. Speaker
    readonly property int volume: Math.round((root.sink?.audio?.volume ?? 0) * 100)
    readonly property bool isMuted: root.sink?.audio?.muted ?? true

    readonly property string icon: {
        if (isMuted) return "󰝟"
        if (volume >= 60) return ""
        if (volume >= 30) return ""
        return ""
    }

    // 2. Microphone
    readonly property int micVolume: Math.round((root.source?.audio?.volume ?? 0) * 100)
    readonly property bool isMicMuted: root.source?.audio?.muted ?? true

    readonly property string micIcon: isMicMuted ? "" : ""

    // --- RECORDING DETECTION (Shell Script) ---
    // Uses privacy_dots.sh from https://github.com/alvaniss/privacy-dots
    property bool micActiveState: false

    Process {
        id: micProcess
        command: ["/home/lruego/Gemini/dotfiles/quickshell/scripts/privacy_dots.sh"]
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    const json = JSON.parse(data)
                    // check if class string contains 'mic-on'
                    if (json.class && json.class.includes("mic-on")) {
                        root.micActiveState = true
                    } else {
                        root.micActiveState = false
                    }
                } catch (e) {
                    // JSON parse error or empty output
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

    // Smart logic: Show mic if it is RECORDING (Active Stream)
    // Fallback: If script hasn't run yet, default to !muted? No, safer to default to false.
    readonly property bool isMicActive: micActiveState

    // --- ACTIONS ---
    function toggleMute() {
        if (root.sink?.audio) {
            root.sink.audio.muted = !root.sink.audio.muted
        }
    }

    function toggleMic() {
        if (root.source?.audio) {
            root.source.audio.muted = !root.source.audio.muted
        }
    }
}
