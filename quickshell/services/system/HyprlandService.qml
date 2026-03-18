// services/HyprlandService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../core"
import "../ui"

Item {
    id: root

    // --- DATA EXPOSURE ---
    // Using standard properties instead of aliases for global singletons
    readonly property var workspaces: Hyprland.workspaces
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
                    2500
                );
            }
        }
    }

    // --- PUBLIC API ---
    function goToWorkspace(id) {
        if (root.focusedWorkspace?.id === id) return;
        Hyprland.dispatch(`workspace ${id}`);
    }

    function nextWorkspace() {
        Hyprland.dispatch("workspace m+1");
    }

    function prevWorkspace() {
        Hyprland.dispatch("workspace m-1");
    }
}
