// services/NotificationService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../core"

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
            let rawAppIcon = (n.appIcon && typeof n.appIcon === "string") ? n.appIcon : "";
            let rawAppName = n.appName ? String(n.appName).toLowerCase() : "";

            if (rawAppIcon.startsWith("image://quickshell") || rawAppIcon === "") {
                if (rawAppName === "tailscale" || rawAppName === "tailscale-drop") {
                    safeIconPath = Assets.tailscaleIcon;
                } else if (rawAppName !== "" && rawAppName !== "notify-send") {
                    safeIconPath = rawAppName;
                } else {
                    safeIconPath = ""; // Pass empty string so the UI fallback kicks in cleanly
                }
            } else {
                safeIconPath = rawAppIcon;
            }

            // --- RICH MEDIA DETECTION ---
            let previewImage = "";
            let homeDir = Quickshell.env("HOME") || "/home/lruego";

            // 1. Direct Image Property (often a path)
            if (n.image && typeof n.image === "string" && n.image !== "" && !n.image.startsWith("image://qsimage")) {
                previewImage = n.image;
            }

            // 2. Tailscale File Detection
            let lowerApp = rawAppName.toLowerCase();
            let lowerSum = String(n.summary).toLowerCase();

            if (lowerApp.includes("tailscale") || lowerSum.includes("tailscale")) {
                // Look for any quoted string that might be a filename
                let match = String(n.body).match(/"([^"]+)"/);
                if (match) {
                    let filename = match[1];
                    // If it matched something like 'Saved "file" to "/path"', we want the first quote
                    // but we should check if it has an image extension
                    if (filename.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i)) {
                        previewImage = homeDir + "/Downloads/Taildrop/" + filename;
                    }
                }
            }


            // 3. Fallback to Hints
            if (previewImage === "" && n.hints) {
                let hintPath = n.hints["image-path"] || n.hints["image_path"];
                if (hintPath && typeof hintPath === "string" && !hintPath.startsWith("image://qsimage")) {
                    previewImage = hintPath;
                }
            }

            let ms = n.expireTimeout <= 0 ? 5000 : n.expireTimeout;

            let data = { 
                "summary": String(n.summary),
                "body": String(n.body),
                "icon": safeIconPath,
                "image": previewImage, // Pass the detected image
                "notifId": Number(n.id),
                "timeout": Number(ms),
                "closing": false
            };

            // 3. Update or Append
            let found = false;
            for (let i = 0; i < popupList.count; i++) {
                if (popupList.get(i).notifId === n.id) {
                    let item = popupList.get(i);
                    item.summary = data.summary;
                    item.body = data.body;
                    item.icon = data.icon;
                    item.image = data.image; // Update image
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
    function notify(summary, body, icon, timeout = 3000, image = "") {
        let id = 9000 + popupList.count;
        
        root.popupList.append({ 
            "summary": String(summary),
            "body": String(body),
            "icon": String(icon),
            "image": String(image),
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
