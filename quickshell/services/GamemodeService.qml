// services/GamemodeService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- STATE ---
    property bool isActive: false

    // --- HYPRLAND COLORS ---
    readonly property string activeBorderGaming:          "rgba(bb9af7ee) rgba(e0d4ffee) 45deg"
    readonly property string activeBorderNormal:          "rgba(7aa2f7ee) rgba(c0caf5ee) 45deg"
    readonly property string inactiveBorderGaming:        "rgba(bb9af7aa)"
    readonly property string inactiveBorderNormal:        "rgba(595959aa)"
    readonly property string groupBarActiveGaming:        "rgba(bb9af7ff)"
    readonly property string groupBarActiveNormal:        "rgba(7aa2f7ff)"
    readonly property string groupBarInactiveGaming:      "rgba(24283b88)"
    readonly property string groupBarInactiveNormal:      "rgba(24283b88)"

    // --- POLL PROCESS ---
    Process {
        id: gamemodeProc
        command: ["bash", "-c", "gamemoded -s | grep -q 'is active' && echo true || echo false"]
        stdout: SplitParser {
            onRead: line => {
                let active = line.trim() === "true"
                if (active !== root.isActive) {
                    root.isActive = active
                    applyHyprlandColors(active)
                    console.log("[GamemodeService] Gamemode:", active ? "active" : "inactive")
                }
            }
        }
    }

    // --- HYPRLAND BORDER PROCESSES ---
    Process { id: setActiveBorder;              command: [] }
    Process { id: setInactiveBorder;            command: [] }
    Process { id: setGroupBorderActive;         command: [] }
    Process { id: setGroupBorderInactive;       command: [] }
    Process { id: setGroupBorderLockedActive;   command: [] }
    Process { id: setGroupBorderLockedInactive; command: [] }
    Process { id: setGroupBarActive;            command: [] }
    Process { id: setGroupBarInactive;          command: [] }
    Process { id: setGroupBarLockedActive;      command: [] }
    Process { id: setGroupBarLockedInactive;    command: [] }

    // --- APPLY COLORS ---
    function applyHyprlandColors(gaming) {
        let activeBorder     = gaming ? activeBorderGaming     : activeBorderNormal
        let inactiveBorder   = gaming ? inactiveBorderGaming   : inactiveBorderNormal
        let groupBarActive   = gaming ? groupBarActiveGaming   : groupBarActiveNormal
        let groupBarInactive = gaming ? groupBarInactiveGaming : groupBarInactiveNormal

        // --- GENERAL BORDERS ---
        setActiveBorder.command             = ["hyprctl", "keyword", "general:col.active_border",             activeBorder]
        setInactiveBorder.command           = ["hyprctl", "keyword", "general:col.inactive_border",           inactiveBorder]

        // --- GROUP BORDERS ---
        setGroupBorderActive.command        = ["hyprctl", "keyword", "group:col.border_active",               activeBorder]
        setGroupBorderInactive.command      = ["hyprctl", "keyword", "group:border_inactive",                 inactiveBorder]
        setGroupBorderLockedActive.command  = ["hyprctl", "keyword", "group:col.border_locked_active",        activeBorder]
        setGroupBorderLockedInactive.command= ["hyprctl", "keyword", "group:col.border_locked_inactive",      inactiveBorder]

        // --- GROUP BAR ---
        setGroupBarActive.command           = ["hyprctl", "keyword", "group:groupbar:col.active",             groupBarActive]
        setGroupBarInactive.command         = ["hyprctl", "keyword", "group:groupbar:col.inactive",           groupBarInactive]
        setGroupBarLockedActive.command     = ["hyprctl", "keyword", "group:groupbar:col.locked_active",      groupBarActive]
        setGroupBarLockedInactive.command   = ["hyprctl", "keyword", "group:groupbar:col.locked_inactive",    groupBarInactive]

        // --- RUN ALL ---
        setActiveBorder.running             = true
        setInactiveBorder.running           = true
        setGroupBorderActive.running        = true
        setGroupBorderInactive.running      = true
        setGroupBorderLockedActive.running  = true
        setGroupBorderLockedInactive.running= true
        setGroupBarActive.running           = true
        setGroupBarInactive.running         = true
        setGroupBarLockedActive.running     = true
        setGroupBarLockedInactive.running   = true
    }

    // --- REFRESH TIMER ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gamemodeProc.running = true
    }

    Component.onCompleted: console.log("[GamemodeService] Loaded.")
}
