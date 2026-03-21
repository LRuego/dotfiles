// services/ui/BarState.qml
pragma Singleton
import QtQuick
import Quickshell
import qs.core
import qs.services.system

Item {
    id: root

    // --- MODE ---
    // Possible values: "normal", "peek", "gaming", "focus"
    // Future: "media"
    property string mode: "normal"

    // --- DERIVED STATE ---
    readonly property bool peekMode:   mode === "peek"
    readonly property bool gamingMode: mode === "gaming"
    readonly property bool focusMode:  mode === "focus"
    // readonly property bool mediaMode: mode === "media"  // future

    // --- COLORS ---
    readonly property color accentColor: gamingMode ? Theme.secondary : Theme.overlay

    // --- ACTIONS ---
    function setMode(m) {
        // --- DEBUG ---
        // console.log("[BarState] Mode:", root.mode, "→", m)
        root.mode = m
    }

    function setPeekMode(active) {
        if (active) setMode("peek")
        else setMode(GamemodeService.isActive ? "gaming" : "normal")
    }

    function setFocusMode(active) {
        if (active) setMode("focus")
        else setMode(GamemodeService.isActive ? "gaming" : "normal")
    }

    // --- GAMING MODE AUTO-TRIGGER ---
    Connections {
        target: GamemodeService
        function onIsActiveChanged() {
            if (GamemodeService.isActive) {
                setMode("gaming")
            } else {
                if (root.mode === "gaming") setMode("normal")
            }
        }
    }
}
