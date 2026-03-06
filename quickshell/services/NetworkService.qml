pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

Item {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- STATE ---
    property string statusText: "Off"     // "Eth", "WiFi", "Off"
    property string ssid: ""              // Name of connection

    // --- UI HELPERS ---
    readonly property string icon: {
        if (statusText === "Eth") return Assets.networkWired
        if (statusText === "WiFi") return Assets.networkWireless
        return Assets.networkOff // Disconnected
    }

    readonly property color statusColor: {
        if (statusText === "Off") return Theme.urgent
        return Theme.primary
    }

    // --- MONITORING ---
    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: updateTimer.restart()
        }
        onExited: updateTimer.restart()
    }

    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            if (!monitorProc.running) monitorProc.running = true
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
        const lines = data.trim().split('\n');
        let ethActive = false;
        let ethName = "";
        let wifiActive = false;
        let wifiName = "";

        for (let line of lines) {
            if (!line) continue;
            const parts = line.split(':');
            if (parts.length < 4) continue;

            const type = parts[1];
            const state = parts[2];
            const connName = parts[3];
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
