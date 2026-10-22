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
            // Super+S moves workspaces, then renumbers them with an event Quickshell 0.3.2 ignores.
            if (event.name === "moveworkspacev2" || event.name === "changeworkspaceid") {
                root.settling = true;
                refreshDelay.restart();
            }
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

    // --- WORKSPACE RESYNC ---
    // True while workspaces are being moved/renumbered; the bar holds its last state until it clears.
    property bool settling: false

    Timer {
        id: refreshDelay
        interval: 50
        onTriggered: {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshMonitors();
            settleDelay.restart();
        }
    }

    // The refresh replies arrive asynchronously, so wait for them before releasing the bar.
    Timer {
        id: settleDelay
        interval: 250
        onTriggered: root.settling = false
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

    // Focuses the monitor under the cursor, then hyprsplit's first empty workspace on it.
    readonly property string focusEmptyWorkspaceAtCursorExpr: 'function() local m = hl.get_monitor_at_cursor(); if m then hl.dispatch(hl.dsp.focus({ monitor = m.name })) end; hl.dispatch(hs.dsp.focus({ workspace = "empty" })) end'

    function focusEmptyWorkspaceAtCursor() {
        Hyprland.dispatch(root.focusEmptyWorkspaceAtCursorExpr);
    }

    // --- WINDOW HELPERS (address is hyprctl's "0x..." form) ---
    function _win(address) {
        return root.luaString(`address:${address}`);
    }

    function focusWindow(address) {
        Hyprland.dispatch(`hl.dsp.focus({ window = ${root._win(address)} })`);
    }

    function moveWindowToWorkspace(address, workspaceId) {
        Hyprland.dispatch(`hl.dsp.window.move({ window = ${root._win(address)}, workspace = ${Number(workspaceId)}, follow = false })`);
    }

    function tileWindow(address) {
        Hyprland.dispatch(`hl.dsp.window.float({ window = ${root._win(address)}, action = "disable" })`);
    }

    function toggleGroup(address) {
        Hyprland.dispatch(`hl.dsp.group.toggle({ window = ${root._win(address)} })`);
    }

    // direction: "left" | "right" | "up" | "down"
    function moveWindowIntoGroup(address, direction) {
        Hyprland.dispatch(`hl.dsp.window.move({ window = ${root._win(address)}, into_group = ${root.luaString(direction)} })`);
    }

    // direction: where the window lands, "left" | "right" | "up" | "down"
    function moveWindowOutOfGroup(address, direction) {
        Hyprland.dispatch(`hl.dsp.window.move({ window = ${root._win(address)}, out_of_group = ${root.luaString(direction)} })`);
    }

    // Focuses the window, then sends a layout message to it, e.g. "togglesplit" (dwindle).
    function layoutMessageOn(address, message) {
        Hyprland.dispatch(`function() hl.dispatch(hl.dsp.focus({ window = ${root._win(address)} })); hl.dispatch(hl.dsp.layout(${root.luaString(message)})) end`);
    }

    // Grows/shrinks by a delta; works for either side of a dwindle split.
    function resizeWindowBy(address, dx, dy) {
        Hyprland.dispatch(`hl.dsp.window.resize({ window = ${root._win(address)}, x = ${Number(dx)}, y = ${Number(dy)}, relative = true })`);
    }

    function resizeWindow(address, width, height) {
        Hyprland.dispatch(`hl.dsp.window.resize({ window = ${root._win(address)}, x = ${Number(width)}, y = ${Number(height)} })`);
    }

    // Raw Lua dispatcher expression, e.g. 'hl.dsp.workspace.toggle_special("Discord")'.
    function dispatch(command) {
        Hyprland.dispatch(command);
    }
}
