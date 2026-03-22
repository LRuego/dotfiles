// services/system/PrivacyService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- STATE ---
    property bool micActive: false
    property bool camActive: false
    property bool locActive: false
    property bool scrActive: false

    property string micApp: ""
    property string camApp: ""
    property string locApp: ""
    property string scrApp: ""

    // --- SCRIPT ---
    property string _homeDir: Quickshell.env("HOME") || ""
    property string _scriptPath: _homeDir + "/.config/quickshell/scripts/privacy_dots.sh"

    Process {
        id: privacyProcess
        command: ["bash", root._scriptPath]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let json = JSON.parse(data)
                    let classes = json.class ?? ""
                    root.micActive = classes.includes("mic-on")
                    root.camActive = classes.includes("cam-on")
                    root.locActive = classes.includes("loc-on")
                    root.scrActive = classes.includes("scr-on")

                    // Parse app names from tooltip
                    // tooltip format: "Mic: app  |  Cam: app  |  Location: app  |  Screen sharing: app"
                    let tooltip = json.tooltip ?? ""
                    let parts   = tooltip.split("  |  ")
                    root.micApp = parts[0]?.replace("Mic: ", "").trim() === "off" ? "" : parts[0]?.replace("Mic: ", "").trim() ?? ""
                    root.camApp = parts[1]?.replace("Cam: ", "").trim() === "off" ? "" : parts[1]?.replace("Cam: ", "").trim() ?? ""
                    root.locApp = parts[2]?.replace("Location: ", "").trim() === "off" ? "" : parts[2]?.replace("Location: ", "").trim() ?? ""
                    root.scrApp = parts[3]?.replace("Screen sharing: ", "").trim() === "off" ? "" : parts[3]?.replace("Screen sharing: ", "").trim() ?? ""
                } catch (e) {
                    console.log("[PrivacyService] Failed to parse privacy_dots output:", e)
                }
            }
        }
    }

    Timer {
        interval:         2000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      privacyProcess.running = true
    }
}
