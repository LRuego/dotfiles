// services/ui/NotificationService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.core

Item {
    id: root

    // --- CONFIG ---
    property int  defaultTimeout: 5000
    property int  minRemaining:   500
    property int  historyMax:     100
    property bool dnd:            false

    // --- APP RULES ---
    // Add entries here to customize per-app notification behavior.
    // match:     matched against appName and summary (case-insensitive)
    // transient: if true, shows popup but never stores in history
    // icon:      overrides the resolved icon (use "" to keep default routing)
    property var appRules: []

    Component.onCompleted: {
        appRules = [
            { match: "satty",    transient: true, icon: "satty" },
            { match: "hamr-gtk", transient: true, icon: Assets.hamr }
        ]
        mkdirProcess.running = true
    }

    // --- STATE ---
    property ListModel popupList:     ListModel {}
    property ListModel historyList:   ListModel {}
    property bool      centerVisible: false
    property int       unreadCount:   0
    property var       _activeNotifs: []
    property int       _idCounter:    9000
    property string    _homeDir:      Quickshell.env("HOME") || ""
    property var       _activeTimers:  ({})
    property var       _activeActions: ({})
    property var       _timerStarted:  ({})
    property var       _timerElapsed:  ({})

    onCenterVisibleChanged: {
        if (centerVisible) {
            unreadCount = 0;
            for (let key in root._activeTimers) {
                let t = root._activeTimers[key];
                if (t) t.stop();
                root._activeTimers[key] = null;
            }
            root.popupList.clear();
        }
    }

    // --- PERSISTENCE ---
    property string _historyPath: _homeDir + "/.local/share/quickshell/notifications.json"

    Process {
        id:      mkdirProcess
        command: ["mkdir", "-p", root._homeDir + "/.local/share/quickshell"]
        onExited: historyFile.reload()
    }

    FileView {
        id:   historyFile
        path: root._historyPath

        onLoaded: {
            try {
                let entries = JSON.parse(historyFile.text());
                root.historyList.clear();
                for (let i = 0; i < entries.length; i++) {
                    root.historyList.append(entries[i]);
                }
                root.unreadCount = root.historyList.count;
            } catch (e) {
                console.log("[NotificationService] Failed to parse history file:", e);
            }
        }

        onLoadFailed: (error) => {
            console.log("[NotificationService] History file not found, creating fresh.");
            historyFile.setText("[]");
        }
    }

    // Debounced save — batches rapid writes into one disk operation
    Timer {
        id:       saveDebounce
        interval: 500
        repeat:   false
        onTriggered: root._saveHistory()
    }

    function _saveHistory() {
        let entries = [];
        for (let i = 0; i < historyList.count; i++) {
            let item = historyList.get(i);
            entries.push({
                "appName": item.appName,
                "summary": item.summary,
                "body":    item.body,
                "icon":    item.icon,
                "image":   item.image,
                "count":   item.count,
                "time":    item.time
            });
        }
        historyFile.setText(JSON.stringify(entries, null, 2));
    }

    // --- TIMER COMPONENT ---
    Component {
        id: timerComponent
        Timer {
            property int notifId: -1
            running:  true
            onTriggered: {
                root.dismiss(notifId);
                destroy();
            }
        }
    }

    // --- SERVER ---
    NotificationServer {
        id: server

        imageSupported:       false
        actionIconsSupported: false
        actionsSupported:     true

        onNotification: n => {
            root._activeNotifs.push(n);
            n.closed.connect(() => root.removeFromPopup(n.id));

            let isTransientHint = (n.hints && n.hints["transient"]) ? true : false;
            let rawAppName      = n.appName ? String(n.appName).toLowerCase() : "";
            let rawSummary      = n.summary ? String(n.summary).toLowerCase() : "";

            // --- APP RULES LOOKUP ---
            let rule = null;
            for (let r = 0; r < root.appRules.length; r++) {
                let m = root.appRules[r].match.toLowerCase();
                if (rawAppName.includes(m) || rawSummary.includes(m)) {
                    rule = root.appRules[r];
                    break;
                }
            }
            if (rule?.transient) isTransientHint = true;

            // --- ICON ROUTING ---
            let safeIconPath = "";
            let rawAppIcon   = (n.appIcon && typeof n.appIcon === "string") ? n.appIcon : "";

            if (rule?.icon !== undefined && rule.icon !== "") {
                safeIconPath = rule.icon;
            } else if (rawAppIcon.startsWith("image://quickshell") || rawAppIcon === "") {
                if (rawAppName === "tailscale" || rawAppName === "tailscale-drop") {
                    safeIconPath = Assets.tailscaleIcon;
                } else if (rawAppName !== "" && rawAppName !== "notify-send") {
                    safeIconPath = rawAppName;
                } else {
                    safeIconPath = "";
                }
            } else {
                safeIconPath = rawAppIcon;
            }

            // --- IMAGE DETECTION ---
            let previewImage = "";

            // 1. D-Bus image field
            if (n.image
                    && typeof n.image === "string"
                    && n.image !== ""
                    && !n.image.startsWith("image://qsimage")
                    && (n.image.startsWith("/") || n.image.startsWith("file://"))
                    && n.image.match(/\.(jpg|jpeg|png|gif|webp|svg|ppm)$/i)
                    && (root._homeDir === "" || n.image.startsWith(root._homeDir) || n.image.startsWith("file://" + root._homeDir))) {
                previewImage = n.image;
            }

            // 2. Absolute path in body text (e.g. Satty: 'Saved to "/home/..."')
            if (previewImage === "") {
                let bodyStr = String(n.body);
                let match   = bodyStr.match(/"(\/[^"]+\.(?:jpg|jpeg|png|gif|webp|svg|ppm))"/i)
                           || bodyStr.match(/(\/\S+\.(?:jpg|jpeg|png|gif|webp|svg|ppm))/i);
                if (match) previewImage = match[1];
            }

            // 3. image-path hint
            if (previewImage === "" && n.hints) {
                let hintPath = n.hints["image-path"] || n.hints["image_path"];
                if (hintPath && typeof hintPath === "string") {
                    // Strip trailing metadata like " (16935235 bytes)" appended by notify-send
                    hintPath = hintPath.replace(/\s+\(\d+\s+bytes\)\s*$/, "")
                    if (!hintPath.startsWith("image://qsimage")
                            && (hintPath.startsWith("/") || hintPath.startsWith("file://"))
                            && (root._homeDir === "" || hintPath.startsWith(root._homeDir) || hintPath.startsWith("file://" + root._homeDir))) {
                        previewImage = hintPath;
                    }
                }
            }

            // 4. Encode spaces in file paths for QQuickImage
            if (previewImage !== "") {
                previewImage = previewImage.replace(/ /g, "%20")
            }

            let ms      = n.expireTimeout <= 0 ? root.defaultTimeout : n.expireTimeout;
            let appName = n.appName ? String(n.appName).charAt(0).toUpperCase() + String(n.appName).slice(1) : "Unknown";
            let urgency = (n.hints && n.hints["urgency"] !== undefined) ? Number(n.hints["urgency"]) : 1;

            // Store actions separately — arrays can't go in ListModel
            let hasDefault = false;
            if (n.actions && n.actions.length > 0) {
                root._activeActions[Number(n.id)] = n.actions;
                for (let a = 0; a < n.actions.length; a++) {
                    if (n.actions[a].identifier === "default") {
                        hasDefault = true;
                        break;
                    }
                }
            }

            // Always add to history unless transient
            if (!isTransientHint) {
                root._addToHistory({
                    "summary": String(n.summary),
                    "body":    String(n.body),
                    "icon":    safeIconPath,
                    "image":   previewImage,
                    "appName": appName,
                    "notifId": Number(n.id)
                });
            }

            // Skip popups entirely when DND is on
            if (root.dnd) return;

            // --- POPUP: group by appName ---
            let found = false;
            for (let i = 0; i < popupList.count; i++) {
                let item = popupList.get(i);
                if (item.appName === appName) {
                    popupList.setProperty(i, "summary",    String(n.summary));
                    popupList.setProperty(i, "body",       String(n.body));
                    popupList.setProperty(i, "icon",       safeIconPath);
                    popupList.setProperty(i, "image",      previewImage);
                    popupList.setProperty(i, "count",      item.count + 1);
                    popupList.setProperty(i, "notifId",    Number(n.id));
                    popupList.setProperty(i, "hasDefault", hasDefault);
                    popupList.setProperty(i, "urgency",    urgency);
                    let existingTimer = root._activeTimers[appName];
                    if (existingTimer) {
                        existingTimer.notifId  = Number(n.id);
                        existingTimer.interval = ms;
                        existingTimer.restart();
                        root._timerStarted[appName] = Date.now();
                        root._timerElapsed[appName] = 0;
                    }
                    found = true;
                    break;
                }
            }

            if (!found && !root.centerVisible) {
                popupList.append({
                    "summary":    String(n.summary),
                    "body":       String(n.body),
                    "icon":       safeIconPath,
                    "image":      previewImage,
                    "appName":    appName,
                    "notifId":    Number(n.id),
                    "count":      1,
                    "hasDefault": hasDefault,
                    "urgency":    urgency
                });
                let t = timerComponent.createObject(root, {
                    "notifId":  Number(n.id),
                    "interval": ms
                });
                root._activeTimers[appName] = t;
                root._timerStarted[appName] = Date.now();
                root._timerElapsed[appName] = 0;
            }
        }
    }

    // --- HOVER PAUSE/RESUME ---
    function pauseTimer(appName) {
        let t = root._activeTimers[appName];
        if (t && t.running) {
            let elapsed = Date.now() - (root._timerStarted[appName] || Date.now());
            root._timerElapsed[appName] = (root._timerElapsed[appName] || 0) + elapsed;
            t.stop();
        }
    }

    function resumeTimer(appName) {
        let t = root._activeTimers[appName];
        if (t && !t.running) {
            let elapsed   = root._timerElapsed[appName] || 0;
            let remaining = Math.max(root.minRemaining, t.interval - elapsed);
            t.interval  = remaining;
            root._timerStarted[appName] = Date.now();
            t.start();
        }
    }

    // --- ACTION INVOCATION ---
    function invokeDefault(id) {
        let actions = root._activeActions[id];
        if (actions) {
            for (let i = 0; i < actions.length; i++) {
                if (actions[i].identifier === "default") {
                    actions[i].invoke();
                    break;
                }
            }
        }
        root.dismiss(id);
    }

    // --- HISTORY ---
    function _addToHistory(data) {
        root.unreadCount++;
        for (let i = 0; i < historyList.count; i++) {
            let item = historyList.get(i);
            if (item.appName === data.appName) {
                historyList.setProperty(i, "summary", data.summary);
                historyList.setProperty(i, "body",    data.body);
                historyList.setProperty(i, "image",   data.image);
                historyList.setProperty(i, "count",   item.count + 1);
                historyList.setProperty(i, "time",    Date.now());
                saveDebounce.restart();
                return;
            }
        }
        if (historyList.count >= root.historyMax) historyList.remove(0);
        historyList.append({
            "appName": data.appName,
            "summary": data.summary,
            "body":    data.body,
            "icon":    data.icon,
            "image":   data.image,
            "count":   1,
            "time":    Date.now()
        });
        saveDebounce.restart();
    }

    function clearHistory() {
        historyList.clear();
        saveDebounce.restart();
    }

    function dismissHistory(appName) {
        for (let i = 0; i < historyList.count; i++) {
            if (historyList.get(i).appName === appName) {
                historyList.remove(i);
                saveDebounce.restart();
                return;
            }
        }
    }

    // --- POPUP MANAGEMENT ---
    function removeFromPopup(id) {
        for (let i = 0; i < popupList.count; i++) {
            if (popupList.get(i).notifId === id) {
                let timerKey = popupList.get(i).appName;
                popupList.remove(i);
                root._activeTimers[timerKey]  = null;
                root._activeActions[id]       = null;
                root._timerStarted[timerKey]  = null;
                root._timerElapsed[timerKey]  = null;
                break;
            }
        }
        let exists = root._activeNotifs.some(n => n.id === id);
        if (exists) root._activeNotifs = root._activeNotifs.filter(n => n.id !== id);
    }

    function dismiss(id) {
        root.removeFromPopup(id);
        let nObj = null;
        for (let i = 0; i < root._activeNotifs.length; i++) {
            if (root._activeNotifs[i].id === id) {
                nObj = root._activeNotifs[i];
                break;
            }
        }
        if (nObj && typeof nObj.dismiss === "function") nObj.dismiss();
    }

    // --- PUBLIC API ---
    function notify(summary, body, icon, timeout, image, isTransient) {
        timeout     = timeout     !== undefined ? timeout     : root.defaultTimeout;
        image       = image       !== undefined ? image       : "";
        isTransient = isTransient !== undefined ? isTransient : false;

        let id   = ++root._idCounter;
        let data = {
            "summary":    String(summary),
            "body":       String(body),
            "icon":       String(icon),
            "image":      String(image),
            "appName":    "Quickshell",
            "notifId":    id,
            "count":      1,
            "hasDefault": false,
            "urgency":    1
        };
        if (!root.dnd && !root.centerVisible) {
            root.popupList.append(data);
            let t = timerComponent.createObject(root, { "notifId": id, "interval": timeout });
            root._activeTimers["Quickshell"] = t;
            root._timerStarted["Quickshell"] = Date.now();
            root._timerElapsed["Quickshell"] = 0;
        }
        if (!isTransient) root._addToHistory(data);
    }
}
