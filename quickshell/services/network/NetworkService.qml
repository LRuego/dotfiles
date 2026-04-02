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
    property int    signal: 0
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

    // --- SIGNAL FETCH ---
    Process {
        id: signalProc
        property string fullOutput: ""
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]
        stdout: SplitParser {
            onRead: data => signalProc.fullOutput += data + "\n"
        }
        onRunningChanged: {
            if (running) {
                fullOutput = ""
            } else {
                const lines = fullOutput.trim().split("\n")
                for (let line of lines) {
                    if (line.startsWith("yes:")) {
                        root.signal = parseInt(line.split(":")[1])
                        break
                    }
                }
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
            root.signal = 100
	    if (signalProc.running) signalProc.running = false
        } else if (wifiActive) {
            root.statusText = "WiFi"
            root.ssid = wifiName
            if (!signalProc.running) signalProc.start()
        } else {
            root.statusText = "Off"
            root.ssid = ""
            root.signal = 0
	    if (signalProc.running) signalProc.running = false
        }
    }

    Component.onCompleted: {
        // --- DEBUG ---
        // console.log("[NetworkService] Loaded.")
        statusProc.running = true
    }
}
