// services/system/UpdateService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * UpdateService — polls for pending pacman/AUR updates.
 *
 * Runs `checkupdates` (official repos) and `paru -Qua` (AUR) on startup,
 * then every hour, or on-demand via refresh().
 *
 * Official packages are additionally checked against the core list via
 * `pacman -Sl core` so [core] packages can be flagged in the UI.
 */
Singleton {
    id: root

    property var    extraUpdates: []
    property var    aurUpdates:   []
    readonly property int totalCount: extraUpdates.length + aurUpdates.length
    property bool   checking:     false
    property string lastChecked:  ""
    property bool   panelCollapsed: true

    property bool _extraDone: false
    property bool _aurDone:   false
    property bool _coreDone:  false
    property var  _extraRaw:  []
    property var  _aurRaw:    []
    property var  _coreNames: []

    Component.onCompleted: refresh()

    Timer {
        interval:    60 * 60 * 1000
        repeat:      true
        running:     true
        onTriggered: root.refresh()
    }

    Process {
        id:      checkupdatesProc
        command: ["checkupdates"]
        stdout: SplitParser {
            onRead: function(line) {
                const pkg = root._parseLine(line)
                if (pkg) root._extraRaw.push(pkg)
            }
        }
        onExited: function(code) {
            root._extraDone = true
            root._tryFinalize()
        }
    }

    Process {
        id:      paruProc
        command: ["paru", "-Qua"]
        stdout: SplitParser {
            onRead: function(line) {
                const pkg = root._parseLine(line)
                if (pkg) root._aurRaw.push(pkg)
            }
        }
        onExited: function(code) {
            root._aurDone = true
            root._tryFinalize()
        }
    }

    Process {
        id:      coreListProc
        command: ["pacman", "-Sl", "core"]
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(" ")
                if (parts.length >= 2) root._coreNames.push(parts[1])
            }
        }
        onExited: function(code) {
            root._coreDone = true
            root._tryFinalize()
        }
    }

    function refresh() {
        if (checking) return
        checking   = true
        _extraDone = false
        _aurDone   = false
        _coreDone  = false
        _extraRaw  = []
        _aurRaw    = []
        _coreNames = []

        checkupdatesProc.running = true
        paruProc.running         = true
        coreListProc.running     = true
    }

    function _parseLine(line) {
        line = line.trim()
        if (!line) return null
        const m = line.match(/^(\S+)\s+(\S+)\s+->\s+(\S+)/)
        if (!m) return null
        return { name: m[1], current: m[2], next: m[3], isCore: false }
    }

    function _tryFinalize() {
        if (!_extraDone || !_aurDone || !_coreDone) return
        const coreSet = new Set(_coreNames)
        extraUpdates = _extraRaw.map(pkg => ({
            name:    pkg.name,
            current: pkg.current,
            next:    pkg.next,
            isCore:  coreSet.has(pkg.name)
        }))
        aurUpdates  = _aurRaw.slice()
        checking    = false
        lastChecked = new Date().toISOString()
    }
}
