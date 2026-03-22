// services/network/TailscaleService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // --- STATE ---
    property bool   connected:    false
    property bool   targetActive: false
    property bool   transitioning: false
    property string activeExitNode: ""

    readonly property bool realActive: connected
    readonly property bool active:     transitioning ? targetActive : realActive

    // --- DATA ---
    property var    peers:   []
    property string _buffer: ""

    // --- MENU POSITIONING ---
    property bool menuOpen:   false
    property var  menuAnchor: null

    // --- LOGIC ---
    Process {
        id: tailscaleProc
        command: ["tailscale", "status", "--json"]
        stdout: SplitParser {
            onRead: data => root._buffer += data
        }
        onExited: (code) => {
            if (transitioning) {
                root._buffer = "";
                return;
            }

            if (code === 0 && root._buffer.length > 0) {
                try {
                    let parsed = JSON.parse(root._buffer);
                    root.connected = (parsed.BackendState === "Running");

                    // Active exit node IP if any
                    let activeExitNodeIP = parsed.ExitNodeStatus?.TailscaleIPs?.[0] ?? null;
                    root.activeExitNode  = activeExitNodeIP ?? "";

                    let newPeers = [];

                    if (parsed.Self) {
                        newPeers.push({
                            "name":             parsed.Self.HostName,
                            "dnsName":          parsed.Self.DNSName,
                            "ip":               parsed.Self.TailscaleIPs[0],
                            "os":               parsed.Self.OS,
                            "online":           true,
                            "tags":             parsed.Self.Tags,
                            "lastSeen":         parsed.Self.LastSeen,
                            "isSelf":           true,
                            "isExitNode":       false,
                            "isActiveExitNode": false
                        });
                    }

                    if (parsed.Peer) {
                        for (let key in parsed.Peer) {
                            let p = parsed.Peer[key];
                            let peerIP = p.TailscaleIPs[0];
                            newPeers.push({
                                "name":             (p.HostName === "localhost") ? p.DNSName.split(".")[0] : p.HostName,
                                "dnsName":          p.DNSName,
                                "ip":               peerIP,
                                "os":               p.OS,
                                "online":           p.Online,
                                "tags":             p.Tags,
                                "lastSeen":         p.LastSeen,
                                "isSelf":           false,
                                "isExitNode":       p.ExitNodeOption ?? false,
                                "isActiveExitNode": peerIP === activeExitNodeIP
                            });
                        }
                    }

                    // Self first, then online, then alphabetical
                    newPeers.sort((a, b) => {
                        if (a.isSelf)              return -1;
                        if (b.isSelf)              return 1;
                        if (a.online && !b.online) return -1;
                        if (!a.online && b.online) return 1;
                        return a.name.localeCompare(b.name);
                    });

                    root.peers = newPeers;
                } catch (e) {
                    root.peers = [];
                }
            } else {
                root.connected      = false;
                root.activeExitNode = "";
                root.peers          = [];
            }
            root._buffer = "";
        }
    }

    // --- TOGGLE PROCESSES ---
    Process {
        id: tailscaleUp
        command: ["tailscale", "up"]
        onExited: (code) => { watchdog.stop(); finalizeTransition(); }
    }

    Process {
        id: tailscaleDown
        command: ["tailscale", "down"]
        onExited: (code) => { watchdog.stop(); finalizeTransition(); }
    }


    // --- WATCHDOG ---
    Timer {
        id:       watchdog
        interval: 10000
        onTriggered: {
            tailscaleUp.running   = false;
            tailscaleDown.running = false;
            finalizeTransition();
        }
    }

    function finalizeTransition() {
        let t = Qt.createQmlObject(
            "import QtQuick; Timer { interval: 1000; onTriggered: { root.transitioning = false; tailscaleProc.running = true; destroy(); } }",
            root
        );
        t.start();
    }

    Timer {
        interval:         10000
        running:          !transitioning
        repeat:           true
        triggeredOnStart: true
        onTriggered:      tailscaleProc.running = true
    }

    // --- ACTIONS ---
    function openMenu(item) {
        if (item !== undefined) root.menuAnchor = item;
        menuOpen = !menuOpen;
        if (menuOpen) tailscaleProc.running = true;
    }

    function toggle() {
        if (transitioning) return;
        transitioning = true;
        targetActive  = !realActive;
        watchdog.start();
        if (realActive) tailscaleDown.running = true;
        else            tailscaleUp.running   = true;
    }

}
