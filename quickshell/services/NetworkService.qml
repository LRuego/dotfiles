import QtQuick
import Quickshell
import Quickshell.Io
import "../theme.js" as Theme

Item {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- STATE ---
    property string statusText: "Off"     // "Eth", "WiFi", "Off"
    property string ssid: ""              // Name of connection

    // --- UI HELPERS ---
    readonly property string icon: {
      if (statusText === "Eth") return ""
        if (statusText === "WiFi") return ""
        return "󰤮" // Disconnected
    }

    readonly property color statusColor: {
        if (statusText === "Off") return Theme.subtext
        return Theme.primary
    }

    // --- MONITORING ---
    // Watches for realtime changes via nmcli monitor
    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]

        stdout: SplitParser {
            // Debounce updates: only trigger status fetch if the timer isn't already running
            onRead: updateTimer.restart()
        }

        onExited: updateTimer.restart()
    }

    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            if (!monitorProc.running) {
                monitorProc.running = true
            }
            statusProc.running = true
        }
    }

    // --- STATUS FETCH ---
    // Snapshots the current device state
    Process {
        id: statusProc

        property string fullOutput: ""

        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]

        stdout: SplitParser {
            // SplitParser strips newlines, so we must add them back
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
        // if (root.debug) console.log("[Net] Raw Data:\n" + data)

        const lines = data.trim().split('\n');

        let ethActive = false;
        let ethName = "";

        let wifiActive = false;
        let wifiName = "";

        for (let line of lines) {
            if (!line) continue;
            // Format: DEVICE:TYPE:STATE:CONNECTION
            // Example: eth0:ethernet:connected:Wired connection 1
            const parts = line.split(':');
            if (parts.length < 4) continue;

            const type = parts[1];
            const state = parts[2];
            const connName = parts[3];

            if (root.debug) console.log(`[Net] Found: ${parts[0]} | Type: ${type} | State: ${state} | Conn: ${connName}`)

            const isConnected = state === "connected" || state.startsWith("100");

            if (isConnected) {
                if (type === "ethernet") {
                    ethActive = true;
                    ethName = connName;
                } else if (type === "wifi") {
                    wifiActive = true;
                    wifiName = connName;
                }
            }
        }

        // Apply Priority: Ethernet > WiFi > Off
        if (ethActive) {
            root.statusText = "Eth";
            root.ssid = ethName;
        } else if (wifiActive) {
            root.statusText = "WiFi";
            root.ssid = wifiName;
        } else {
            root.statusText = "Off";
            root.ssid = "";
        }
    }
}
