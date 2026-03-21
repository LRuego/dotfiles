// services/network/NetworkService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- STATE ---
    property string statusText: "Off"
    property string ssid: ""
    property int    restartAttempts: 0

    // --- MONITORING ---
    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: {
                root.restartAttempts = 0
                updateTimer.restart()
            }
        }
        onExited: {
            if (root.restartAttempts < 5) {
                root.restartAttempts++
                if (!restartDelay.running)
                    restartDelay.start()
            } else {
                console.warn("[NetworkService] nmcli monitor failed too many times, giving up")
            }
        }
    }

    // --- RESTART BACKOFF ---
    Timer {
        id: restartDelay
        interval: 2000
        onTriggered: {
            root.restartAttempts = 0
            monitorProc.running = true
        }
    }

    // --- UPDATE DEBOUNCE ---
    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            if (!statusProc.running)
                statusProc.running = true
        }
    }

    // --- STATUS FETCH ---
    Process {
        id: statusProc
        property string fullOutput: ""
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        stdout: SplitParser {
            onRead: data => statusProc.fullOutput += data + "\n"
        }
        onRunningChanged: {
            if (running) {
                fullOutput = ""
            } else {
                root.parseStatus(fullOutput)
            }
        }
    }

    // --- PARSER ---
    function parseStatus(data) {
        const lines = data.trim().split('\n')
        let ethActive = false
        let ethName = ""
        let wifiActive = false
        let wifiName = ""

        for (let line of lines) {
            if (!line) continue
            const parts = line.split(':')
            if (parts.length < 4) continue

            const type = parts[1]
            const state = parts[2]
            const connName = parts.slice(3).join(':')
            const isConnected = state === "connected" || state.startsWith("100")

            if (isConnected) {
                if (type === "ethernet") {
                    ethActive = true
                    ethName = connName
                } else if (type === "wifi") {
                    wifiActive = true
                    wifiName = connName
                }
            }
        }

        if (ethActive) {
            root.statusText = "Eth"
            root.ssid = ethName
        } else if (wifiActive) {
            root.statusText = "WiFi"
            root.ssid = wifiName
        } else {
            root.statusText = "Off"
            root.ssid = ""
        }
    }

    Component.onCompleted: {
        // --- DEBUG ---
        // console.log("[NetworkService] Loaded.")
        statusProc.running = true
    }
}
