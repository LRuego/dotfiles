//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "./components/bar"
import "./components/base"
import "./components/notifications"
import "./components/menus"
import "./services/input"
import "./services/system"
import "./services/ui"
import "./core"

ShellRoot {
    id: root

    // Main Windows
    Bar {}
    NotificationPopup {}

    Loader {
        active:          NotificationService.centerVisible
        sourceComponent: NotificationCenter {}
    }

    // Menus
    TailscaleMenu {}
    SampleMenu { id: sampleMenu }

    // Global Components
    ToolTip { id: globalTooltip }

    Component.onCompleted: {
        // --- GLOBAL HOTKEYS ---
        
        // Hold Alt to Peek
        InputService.onHold("KEY_LEFTALT", 500,
            () => { BarState.setPeekMode(true) },
            () => { BarState.setPeekMode(false) }
        )

        // Double-tap Alt for Notification Center
        InputService.onDoubleTap("KEY_LEFTALT", 300, () => {
            NotificationService.centerVisible = !NotificationService.centerVisible
        })

        NotificationService.notify(
            "Quickshell",
            "Configuration Loaded",
            Assets.quickshell,
            2500,
            "",
            true
        );

        GamemodeService
        InputService
        ThemeState
    }

    IpcHandler {
        target: "shell"

        function softReload(): void {
            Quickshell.reload(false)
        }
    }
}
