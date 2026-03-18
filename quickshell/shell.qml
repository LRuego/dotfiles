//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "./components/bar"
import "./components/base"
import "./components/notifications"
import "./components/menus"
import "./services"
import "./core"

ShellRoot {
    id: root
    
    // Main Windows
    Bar {}
    NotificationPopup {}
    
    // Menus
    TailscaleMenu {}
    SampleMenu { id: sampleMenu }
    
    // Global Components
    ToolTip { id: globalTooltip }

    // Quickshell Startup Notification
    Component.onCompleted: {
        NotificationService.notify(
            "Quickshell", 
            "Configuration Loaded", 
            Assets.quickshell, 
            2500 
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
