// services/system/HyprlandService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.services.ui

Item {
    id: root

    // --- DATA EXPOSURE ---
    readonly property var workspaces:       Hyprland.workspaces
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace

    // --- COMPOSITOR EVENTS ---
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                NotificationService.notify(
                    "Hyprland",
                    "Configuration Reloaded",
                    Assets.hyprland,
                    2500,
                    "",
                    true
                );
            }
        }
    }

    // --- PUBLIC API ---

    function getWorkspacesForScreen(screen) {
        if (!screen) return [];
        const mon = Hyprland.monitorFor(screen);
        if (!mon) return [];

        var allWs = Hyprland.workspaces.values;
        var res = [];

        for (var i = 0; i < allWs.length; i++) {
            var ws = allWs[i];
            if (!ws || ws.id < 0) continue;

            // Simple monitor match: check Name or ID
            var isOnMonitor = (ws.monitor && ws.monitor.name === mon.name) || (ws.monitorID === mon.id);

            if (isOnMonitor) {
                res.push(ws);
            }
        }

        return res.sort((a, b) => a.id - b.id);
    }

    // Dispatches are Lua since the hyprland.lua migration; `hs` is hyprsplit, exposed from hyprland.lua.
    function luaString(value) {
        return JSON.stringify(String(value));
    }

    function goToWorkspace(id) {
        if (root.focusedWorkspace?.id === id) return;
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${Number(id)} })`);
    }

    function nextWorkspace() {
        Hyprland.dispatch(`hs.dsp.focus({ workspace = "m+1" })`);
    }

    function prevWorkspace() {
        Hyprland.dispatch(`hs.dsp.focus({ workspace = "m-1" })`);
    }

    function toggleSpecialWorkspace(name) {
        Hyprland.dispatch(`hl.dsp.workspace.toggle_special(${root.luaString(name)})`);
    }

    // Raw Lua dispatcher expression, e.g. 'hl.dsp.workspace.toggle_special("Discord")'.
    function dispatch(command) {
        Hyprland.dispatch(command);
    }
}
