// services/system/CalendarService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Item {
    id: root

    property var    events:      []
    property string _homeDir:    Quickshell.env("HOME") || ""
    property string _cacheDir:   _homeDir + "/.local/share/quickshell"
    property string _cacheFile:  _cacheDir + "/holidays.ics"
    property string _scriptPath: Qt.resolvedUrl("../../scripts/fetch_holidays.sh").toString().replace("file://", "")
    property string _calUrl:     UserConfig.holidayCalendarUrl

    // --- FETCH & PARSE ---
    Process {
        id: fetchProcess
        command: ["bash", root._scriptPath, root._calUrl, root._cacheFile]
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim()
                if (trimmed === "" || trimmed === "FETCHED" || trimmed === "CACHED") return
                let parts = trimmed.split("|")
                if (parts.length >= 2) {
                    let entry     = { date: parts[0], name: parts.slice(1).join("|").trim() }
                    let newEvents = root.events.slice()
                    newEvents.push(entry)
                    root.events   = newEvents
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) console.log("[CalendarService] fetch-holidays.sh failed with code:", code)
        }
    }

    Component.onCompleted: {
        if (root._calUrl !== "") {
            fetchProcess.running = true
        } else {
            console.log("[CalendarService] No holiday calendar URL set in UserConfig")
        }
    }

    // --- PUBLIC API ---
    function getEventsForDate(dateStr) {
        return root.events.filter(e => e.date === dateStr)
    }

    function hasEvents(dateStr) {
        return root.events.some(e => e.date === dateStr)
    }
}
