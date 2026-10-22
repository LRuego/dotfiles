// services/network/VncService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services.system
import qs.services.ui

// wayvnc.service: running state, connected clients (live from `wayvncctl event-receive`) and the capture setting.
Item {
    id: root

    readonly property string serviceName: "wayvnc.service"
    readonly property string configPath:  Quickshell.env("HOME") + "/.config/wayvnc/config"
    readonly property string capturePath: Quickshell.env("HOME") + "/.local/state/wayvnc/capture.env"

    // --- STATE ---
    property bool   active:        false
    property bool   transitioning: false   // between a start/stop/restart request and the next status check
    property var    clients:       []      // [{ id, address }] from wayvncctl client-list
    property string capture:       "all"   // saved setting: "all" (every monitor) or an output name
    property string address:       ""      // from the wayvnc config
    property string port:          "5900"
    readonly property string endpoint: root.address ? `${root.address}:${root.port}` : ""

    // A client's Tailscale peer ({ name, os, ... }), when its address is one; else null.
    function peerFor(address) {
        return TailscaleService.peers.find(p => p.ip === address) ?? null
    }

    function clientName(client) {
        return root.peerFor(client.address)?.name ?? client.address
    }

    // --- ACTIONS ---
    function toggle() {
        root._run(["systemctl", "--user", root.active ? "stop" : "start", root.serviceName])
    }

    function disconnect(id) {
        root._run(["wayvncctl", "client-disconnect", String(id)])
    }

    function copyAddress() {
        if (!root.endpoint) return
        UtilService.copyToClipboard(root.endpoint)
        NotificationService.notify("VNC", `Copied ${root.endpoint}`, Assets.vnc, 1500, "", true)
    }

    // "all" or an output name. Saved for the next start; single monitor to single monitor switches live,
    // anything involving "all" restarts wayvnc (it can't leave or enter all-monitors mode while running).
    function setCapture(mode) {
        if (mode === root.capture) return
        let live = root.active && root.capture !== "all" && mode !== "all"
        root.capture = mode
        captureWriter.after = live ? ["wayvncctl", "output-set", mode]
                                   : (root.active ? ["systemctl", "--user", "restart", root.serviceName] : [])
        captureWriter.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf "WAYVNC_CAPTURE=%s\\n" "$2" > "$1"',
                                 "sh", root.capturePath, mode === "all" ? "--desktop" : `--output=${mode}`]
        captureWriter.running = true
    }

    function refresh() {
        statusProc.running = true
        if (root.active) clientsProc.running = true
    }

    function _run(cmd) {
        root.transitioning = true
        actionProc.command = cmd
        actionProc.running = true
    }

    function _onEvent(line) {
        let ev
        try { ev = JSON.parse(line) } catch (e) { return }   // wayvncctl also prints plain error lines
        let p = ev.params ?? {}
        if (ev.method === "client-connected" || ev.method === "client-disconnected") {
            let who = root.peerFor(p.address)?.name ?? p.address
            if (ev.method === "client-connected")
                NotificationService.notify("VNC", `${who} connected`, Assets.vnc, 3000, "", true)
            else
                NotificationService.notify("VNC", "A viewer disconnected", Assets.vnc, 2000, "", true)
            clientsProc.running = true
        } else if (ev.method === "wayvnc-startup" || ev.method === "wayvnc-shutdown") {
            if (ev.method === "wayvnc-shutdown") root.clients = []
            root.refresh()
        }
    }

    // --- PROCESSES ---
    Process {
        id: actionProc
        onExited: root.refresh()
    }

    Process {
        id: captureWriter
        property var after: []
        onExited: {
            if (after.length) {
                actionProc.command = after
                actionProc.running = true
                root.transitioning = true
            }
        }
    }

    Process {
        id:      statusProc
        command: ["systemctl", "--user", "is-active", root.serviceName]
        stdout: StdioCollector {
            onStreamFinished: {
                root.active = text.trim() === "active"
                root.transitioning = false
                if (!root.active) root.clients = []
            }
        }
    }

    Process {
        id:      clientsProc
        command: ["wayvncctl", "--json", "client-list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.clients = JSON.parse(text) } catch (e) { root.clients = [] }
            }
        }
    }

    // Long-lived: waits for wayvnc to start (-w) and follows it across restarts (-r).
    Process {
        id:      eventProc
        command: ["wayvncctl", "--json", "--wait", "--reconnect", "event-receive"]
        running: true
        stdout: SplitParser { onRead: (line) => root._onEvent(line) }
        onExited: eventRestart.start()
    }

    Timer {
        id:          eventRestart
        interval:    5000
        onTriggered: eventProc.running = true
    }

    // Fallback in case an event is missed.
    Timer {
        interval:         5000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      root.refresh()
    }

    // --- FILES ---
    FileView {
        path:         root.configPath
        printErrors:  false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            let t = text()
            root.address = (t.match(/^\s*address\s*=\s*(\S+)/m) ?? [])[1] ?? ""
            root.port    = (t.match(/^\s*port\s*=\s*(\d+)/m) ?? [])[1] ?? "5900"
        }
    }

    FileView {
        path:        root.capturePath
        printErrors: false
        onLoaded: {
            let m = text().match(/WAYVNC_CAPTURE=--output=(\S+)/)
            root.capture = m ? m[1] : "all"
        }
    }
}
