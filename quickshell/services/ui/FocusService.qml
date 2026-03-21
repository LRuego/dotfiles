// services/ui/FocusService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    // Use a list property for better reactivity
    property list<var> activeMenus: []

    function registerMenu(window) {
        // console.log("[FocusService] Registering menu: " + window);
        let current = Array.from(activeMenus);
        if (!current.includes(window)) {
            current.push(window);
            activeMenus = current;
        }
    }

    function unregisterMenu(window) {
        // console.log("[FocusService] Unregistering menu: " + window);
        let current = Array.from(activeMenus);
        let index = current.indexOf(window);
        if (index !== -1) {
            current.splice(index, 1);
            activeMenus = current;
        }
    }

    // THE GLOBAL GRAB
    HyprlandFocusGrab {
        // React strictly to the list length
        active: root.activeMenus.length > 0
        
        // Use spread to ensure we provide a clean window list
        windows: Array.from(root.activeMenus)
        
        onCleared: {
            // console.log("[FocusService] Grab cleared! Dismissing " + root.activeMenus.length + " menus.");
            
            // Loop through a copy to avoid modification-during-iteration issues
            let toDismiss = Array.from(root.activeMenus);
            for (let i = 0; i < toDismiss.length; i++) {
                let menu = toDismiss[i];
                if (menu && menu.dismissed) {
                    menu.dismissed();
                }
            }
            
            // Explicitly clear the list
            root.activeMenus = [];
        }
    }
}
