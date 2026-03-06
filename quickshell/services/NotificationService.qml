pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    // Active Popups Only (STRICTLY PRIMITIVES ONLY)
    property ListModel popupList: ListModel {} 

    // Hidden array to safely hold the physical C++ objects for dismissal
    property var _activeNotifs: []

    // --- SERVER ---
    NotificationServer {
        id: server
        
        // CRITICAL FIX: Disable raw image support.
        // This forces applications like Discord to send theme icon names (e.g. "discord")
        // instead of raw memory buffers, completely preventing the "Cannot use same item" 
        // Wayland/Qt segmentation fault.
        imageSupported: false
        actionIconsSupported: false

        onNotification: n => {
            root._activeNotifs.push(n);
            n.closed.connect(() => root.finalizeRemoval(n.id));

            // EXTREMELY DEFENSIVE ICON ROUTING
            let safeIconPath = "";
            let rawAppIcon = n.appIcon ? String(n.appIcon) : "";
            let rawAppName = n.appName ? String(n.appName).toLowerCase() : "";

            if (rawAppIcon.startsWith("image://quickshell") || rawAppIcon === "") {
                if (rawAppName !== "" && rawAppName !== "notify-send") {
                    safeIconPath = rawAppName;
                } else {
                    safeIconPath = ""; // Pass empty string so the UI fallback kicks in cleanly
                }
            } else {
                safeIconPath = rawAppIcon;
            }

            let ms = n.expireTimeout <= 0 ? 5000 : n.expireTimeout;

            let data = { 
                "summary": String(n.summary),
                "body": String(n.body),
                "icon": safeIconPath,
                "notifId": Number(n.id),
                "timeout": Number(ms),
                "closing": false
            };

            // 3. Update or Append
            let found = false;
            for (let i = 0; i < popupList.count; i++) {
                if (popupList.get(i).notifId === n.id) {
                    // Update properties individually instead of replacing the whole item.
                    // This prevents Qt from destroying and recreating the delegate while it's active.
                    let item = popupList.get(i);
                    item.summary = data.summary;
                    item.body = data.body;
                    item.icon = data.icon;
                    item.timeout = data.timeout;
                    found = true;
                    break;
                }
            }

            if (!found) {
                root.popupList.append(data);
            }
        }
    }

    // --- PUBLIC API ---
    function notify(summary, body, icon, timeout = 3000) {
        let id = 9000 + popupList.count;
        
        root.popupList.append({ 
            "summary": String(summary),
            "body": String(body),
            "icon": String(icon),
            "notifId": id,
            "timeout": timeout,
            "closing": false
        });
    }

    // Called by the UI when the fade-out animation finishes
    function finalizeRemoval(id) {
        for (let i = 0; i < popupList.count; i++) {
            if (popupList.get(i).notifId === id) {
                popupList.remove(i);
                break;
            }
        }
        root._activeNotifs = root._activeNotifs.filter(n => n.id !== id);
    }

    // Called by the UI when a user clicks the card or the timeout hits 0
    function dismiss(id) {
        // 1. Trigger the visual close animation in the model
        for (let i = 0; i < popupList.count; i++) {
            let item = popupList.get(i);
            if (item.notifId === id) {
                item.closing = true; 
                break;
            }
        }
        
        // 2. Safely call dismiss on the physical object
        let nativeObj = root._activeNotifs.find(n => n.id === id);
        if (nativeObj && typeof nativeObj.dismiss === "function") {
            nativeObj.dismiss();
        }
    }
}
