// services/system/TheTowerService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services.ui

Item {
    id: root

    // --- CONFIG ---
    // Values live in UserConfig; aliased here so the rest of the service reads cleanly.
    readonly property string serviceName:    UserConfig.towerService
    readonly property string daemonPath:     UserConfig.towerDaemon
    readonly property string statusPath:     UserConfig.towerStatusFile
    readonly property string towerPackage:   UserConfig.towerPackage
    readonly property string rendPath:       UserConfig.towerRendPath
    readonly property string heliumLauncher: UserConfig.towerHeliumLauncher
    readonly property string heliumProfile:  UserConfig.towerHeliumProfile
    readonly property int    waydroidWidth:  UserConfig.towerWaydroidWidth
    readonly property int    workspace:      UserConfig.towerWorkspace

    // --- DAEMON STATE (from towerd.service's status.json) ---
    property bool daemonActive: false
    property var  status:       ({})

    // Each part: enabled, state (off|idle|busy|waiting|error), detail, error, next, plus stats.
    readonly property var run: _part("run")
    readonly property var gem: _part("gem")

    // --- LOGS (one file per part, written by the daemon) ---
    readonly property string logDir: root.status.logDir ?? (Quickshell.env("HOME") + "/.local/state/towersuite/towerd/logs")
    // Part whose log is loaded ("" = none); set while its page is open, so nothing is read in the background.
    property string logPart: ""
    // true: load <part>.debug.log (everything, incl. DEBUG) instead of <part>.log (INFO and up).
    property bool   logDebug: false
    // Newest last: { date: "2026-10-17", time: "14:29:34", level: "INFO"|"WARNING"|"ERROR", text }
    property var    logEntries: []

    readonly property bool scriptsEnabled: run.enabled || gem.enabled
    readonly property bool scriptsBusy:    run.state === "busy" || gem.state === "busy"

    // --- WINDOW STATE (hyprctl addresses, "" when absent) ---
    property string waydroidAddress: ""
    property string rendAddress:     ""
    property string heliumAddress:   "" // the Helium window grouped with Rend, not any Helium
    property var    _clients:        []

    // --- LAUNCH STATE ---
    property bool   launching:       false
    property string launchStep:      ""
    property string launchError:     ""
    property int    targetWorkspace: -1
    property string mode:            "" // "launch" | "fix"

    readonly property bool towerOpen: waydroidAddress !== "" && rendAddress !== ""

    // --- PUBLIC API ---
    // key: "run" | "gem"; starts the service too if it's down.
    function setPart(key, on) {
        Quickshell.execDetached([root.daemonPath, "set", key, on ? "on" : "off"])
        if (on && !root.daemonActive) Quickshell.execDetached(["systemctl", "--user", "start", root.serviceName])
    }

    function togglePart(key) {
        root.setPart(key, !root._part(key).enabled)
    }

    // Starts or stops towerd.service; the started/stopped notification comes from the status poll.
    function toggleService() {
        serviceToggle.command = ["systemctl", "--user", root.daemonActive ? "stop" : "start", root.serviceName]
        serviceToggle.running = true
    }

    // Opens the part's full log in the floating terminal (term-float window rule).
    // key: "run" | "gem"; dryRun detects and logs without tapping. Works while the part is off.
    function runOnce(key, dryRun) {
        Quickshell.execDetached([root.daemonPath, "run", key].concat(dryRun ? ["--dry"] : []))
        if (!root.daemonActive) Quickshell.execDetached(["systemctl", "--user", "start", root.serviceName])
    }

    function openLog(key) {
        Quickshell.execDetached(["ghostty", "--title=term-float", "-e", "bat", "--pager=less -R +G", root._logPath(key)])
    }

    function _logPath(key) {
        return `${root.logDir}/${key}${root.logDebug ? ".debug" : ""}.log`
    }

    function _onLog(text) {
        let lines = text.split("\n").filter(l => l !== "").slice(-100)
        root.logEntries = lines.map(l => {
            let m = l.match(/^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w+) (.*)$/)
            return m ? { date: m[1], time: m[2], level: m[3], text: m[4] } : { date: "", time: "", level: "INFO", text: l }
        })
    }

    function refresh() {
        statusProcess.running = true
        statusFile.reload()
    }

    // --- STATUS HELPERS ---
    function _part(key) {
        let p = root.daemonActive && root.status.parts ? root.status.parts[key] : null
        return p ?? { enabled: false, state: "off", detail: root.daemonActive ? "" : "Service stopped", error: "" }
    }

    function _onStatus(text) {
        let next
        try {
            next = JSON.parse(text)
        } catch (e) {
            return
        }
        root.status = next
    }

    // Opens Waydroid, Rend and Helium on the tower workspace.
    function launch() {
        root._begin("launch")
    }

    // Reopens missing apps, pulls them onto Waydroid's workspace, regroups and resizes.
    function fixLayout() {
        root._begin("fix")
    }

    function launchOrFix() {
        if (root.waydroidAddress === "") root.launch()
        else root.fixLayout()
    }

    // `qs ipc call tower layout`: towerd runs this after its crash recovery restarts Waydroid.
    IpcHandler {
        target: "tower"

        function layout(): void {
            root.launchOrFix()
        }
    }

    // Hyprland client object for an address, or null; reactive to the 3s client poll.
    function client(address) {
        return address ? root._byAddress(address) : null
    }

    function _begin(mode) {
        if (root.launching) return
        root.launching       = true
        root.mode            = mode
        root.launchError     = ""
        root.targetWorkspace = root.workspace
        root._step("Checking apps")
        prereqProcess.running = true
    }

    function cancel() {
        if (!root.launching) return
        root._fail("Cancelled")
    }

    // --- CLIENT HELPERS ---
    function _find(cls) {
        let lower = cls.toLowerCase()
        for (let c of root._clients) {
            if (c.mapped && String(c["class"]).toLowerCase() === lower) return c
        }
        return null
    }

    // Class is "Waydroid" for the full UI, then "waydroid.<package>" once an app is in front.
    function _findWaydroid() {
        for (let c of root._clients) {
            if (c.mapped && /^waydroid(\.|$)/i.test(c["class"])) return c
        }
        return null
    }

    function _byAddress(address) {
        for (let c of root._clients) {
            if (c.address === address) return c
        }
        return null
    }

    // A Helium window already in Rend's group, if any.
    function _groupedHelium(rendAddress) {
        let rend = root._byAddress(rendAddress)
        if (!rend) return undefined
        return rend.grouped.find(a => a !== rendAddress && /helium/i.test(root._byAddress(a)?.["class"] ?? ""))
    }

    function _heliumAddresses() {
        return root._clients.filter(c => /helium/i.test(c["class"])).map(c => c.address)
    }

    function _onClients(text) {
        try {
            root._clients = JSON.parse(text)
        } catch (e) {
            return
        }
        let w = root._findWaydroid()
        let r = root._find("rendapp")
        root.waydroidAddress = w ? w.address : ""
        root.rendAddress     = r ? r.address : ""
        if (root.heliumAddress !== "" && !root._byAddress(root.heliumAddress)) root.heliumAddress = ""
        if (root.heliumAddress === "" && r) root.heliumAddress = root._groupedHelium(r.address) ?? ""
        if (root._waiter) root._checkWaiter()
    }

    // Tiles a window and moves it onto the target workspace if it opened elsewhere.
    function _place(address) {
        let c = root._byAddress(address)
        if (!c) return
        if (c.floating) HyprlandService.tileWindow(address)
        if (c.workspace.id !== root.targetWorkspace) HyprlandService.moveWindowToWorkspace(address, root.targetWorkspace)
    }

    // --- LAUNCH SEQUENCE ---
    property var _waiter: null

    // Polls clients until check() returns truthy, then calls done(result); fails after timeoutMs.
    function _waitFor(label, timeoutMs, check, done) {
        root._waiter = { label: label, deadline: Date.now() + timeoutMs, check: check, done: done }
        pollTimer.restart()
        clientsProcess.running = true
    }

    function _checkWaiter() {
        let w = root._waiter
        let result = w.check()
        if (result) {
            root._waiter = null
            w.done(result)
        } else if (Date.now() > w.deadline) {
            root._fail(`Timed out waiting for ${w.label}`)
        }
    }

    function _step(text) {
        root.launchStep = text
    }

    function _fail(reason) {
        root._waiter     = null
        root.launching   = false
        root.launchStep  = ""
        root.launchError = reason
        let what = root.mode === "fix" ? "Layout fix" : "Launch"
        NotificationService.notify("The Tower", `${what} failed: ${reason}`, Assets.theTower, 4000, "", true)
    }

    // Fix mode: pulls whatever is open onto the tower workspace; with neither open it falls back to a normal launch.
    function _fixFromWaydroid() {
        root._step("Finding the apps")
        // Always truthy: just waits for one fresh client list.
        root._waitFor("the apps", 3000, () => ({ waydroid: root._findWaydroid(), rend: root._find("rendapp") }), (found) => {
            if (found.waydroid) {
                let win = found.waydroid
                root._place(win.address)
                // Full UI only, so bring the game to the front.
                if (!/^waydroid\./i.test(win["class"])) Quickshell.execDetached(["waydroid", "app", "launch", root.towerPackage])
                root._startRend()
            } else if (found.rend) {
                root._startWaydroid()
            } else {
                root.mode = "launch"
                root._startWaydroid()
            }
        })
    }

    function _startWaydroid() {
        root._step("Starting Waydroid")
        if (!root._findWaydroid()) Quickshell.execDetached(["waydroid", "show-full-ui"])
        root._waitFor("Waydroid", 90000, () => root._findWaydroid(), (win) => {
            root._place(win.address)
            Quickshell.execDetached(["waydroid", "app", "launch", root.towerPackage])
            root._startRend()
        })
    }

    function _startRend() {
        root._step("Starting Project Rend")
        if (!root._find("rendapp")) Quickshell.execDetached([root.rendPath])
        root._waitFor("Project Rend", 45000, () => root._find("rendapp"), (win) => {
            root._place(win.address)
            if (win.grouped.length === 0) HyprlandService.toggleGroup(win.address)
            root._startHelium(win.address)
        })
    }

    function _startHelium(rendAddress) {
        root._step("Starting Helium")

        // Reuse the Helium already grouped with Rend; re-read clients first since Rend may have just moved.
        let existing = root.heliumAddress !== "" ? root.heliumAddress : root._groupedHelium(rendAddress)
        if (existing) {
            root._waitFor("Helium", 3000, () => root._byAddress(existing) ? existing : null, (address) => {
                root.heliumAddress = address
                root._place(address)
                root._ensureGrouped(rendAddress, address, ["left", "right", "up", "down"])
            })
            return
        }

        // Helium joins the focused unlocked group on open.
        HyprlandService.focusWindow(rendAddress)
        let before = root._heliumAddresses()
        Quickshell.execDetached([root.heliumLauncher, `--profile-directory=${root.heliumProfile}`])
        root._waitFor("Helium", 45000, () => root._heliumAddresses().find(a => !before.includes(a)), (address) => {
            root.heliumAddress = address
            root._place(address)
            root._ensureGrouped(rendAddress, address, ["left", "right", "up", "down"])
        })
    }

    // Falls back to moving Helium into Rend's group one direction at a time.
    function _ensureGrouped(rendAddress, heliumAddress, directions) {
        root._step("Grouping Project Rend and Helium")
        root._waitFor("the group", 1500, () => {
            let rend = root._byAddress(rendAddress)
            return rend && rend.grouped.includes(heliumAddress)
        }, () => root._arrangeTiles())

        // _waitFor's timeout would fail the launch; retry with the next direction first.
        root._waiter.deadline = Infinity
        groupRetry.rendAddress   = rendAddress
        groupRetry.heliumAddress = heliumAddress
        groupRetry.directions    = directions
        groupRetry.restart()
    }

    // Waydroid and Rend's group side by side, either way round; fixes a stacked split.
    function _tilesArranged(w, r) {
        return w.at[0] + w.size[0] <= r.at[0] + 4 || r.at[0] + r.size[0] <= w.at[0] + 4
    }

    // Waydroid must be its own tile: a group (e.g. dragged into Rend's) makes the split check and resize act on the group.
    function _ungroupWaydroid(then) {
        let w = root._findWaydroid()
        if (!w || w.grouped.length === 0) {
            then()
            return
        }
        root._step("Taking Waydroid out of the group")
        if (w.grouped.length === 1) HyprlandService.toggleGroup(w.address) // a group of just Waydroid: dissolve it
        else HyprlandService.moveWindowOutOfGroup(w.address, "left")
        root._waitFor("Waydroid to leave the group", 2000, () => {
            let c = root._byAddress(w.address)
            return c && c.grouped.length === 0
        }, () => then())
    }

    function _arrangeTiles() {
        groupRetry.stop()
        root._ungroupWaydroid(() => root._arrangeSplit())
    }

    function _arrangeSplit() {
        root._step("Arranging tiles")
        let waydroid = root._findWaydroid()
        if (!waydroid || root.rendAddress === "") {
            root._finishLayout()
            return
        }
        root._waitFor("the tiles", 0, () => {
            let w = root._byAddress(waydroid.address)
            let r = root._byAddress(root.rendAddress)
            return !w || !r || root._tilesArranged(w, r)
        }, () => root._finishLayout())
        root._waiter.deadline = Infinity
        arrangeRetry.waydroidAddress = waydroid.address
        arrangeRetry.attempts        = 3
        arrangeRetry.restart()
    }

    function _finishLayout() {
        groupRetry.stop()
        arrangeRetry.stop()
        root._step("Sizing Waydroid")
        let waydroid = root._findWaydroid()
        if (!waydroid) {
            root._fail("Waydroid window disappeared")
            return
        }
        root._place(waydroid.address)
        // Dwindle moves the shared edge by dx either way, so on the right side the delta flips.
        let rend    = root._byAddress(root.rendAddress)
        let onRight = rend && waydroid.at[0] > rend.at[0]
        let dx      = root.waydroidWidth - waydroid.size[0]
        HyprlandService.resizeWindowBy(waydroid.address, onRight ? -dx : dx, 0)
        root._waitFor("Waydroid to resize", 2000, () => {
            let w = root._byAddress(waydroid.address)
            return w && Math.abs(w.size[0] - root.waydroidWidth) <= 6
        }, () => root._done(""))
        // Size is cosmetic, so a miss warns instead of failing.
        root._waiter.deadline = Infinity
        sizeGrace.restart()
    }

    function _done(warning) {
        sizeGrace.stop()
        root._waiter    = null
        root.launching  = false
        root.launchStep = ""
        if (root.mode === "launch" && root.rendAddress !== "") HyprlandService.focusWindow(root.rendAddress)
        let body = (root.mode === "fix" ? "Layout fixed" : `Ready on workspace ${root.targetWorkspace}`) + (warning ? ` (${warning})` : "")
        NotificationService.notify("The Tower", body, Assets.theTower, 2500, "", true)
    }

    Timer {
        id:       groupRetry
        interval: 400
        repeat:   true
        property string rendAddress:   ""
        property string heliumAddress: ""
        property var    directions:    []
        onTriggered: {
            if (!root.launching || !root._waiter) {
                stop()
                return
            }
            let rend = root._byAddress(rendAddress)
            if (rend && rend.grouped.includes(heliumAddress)) return // already grouped, the waiter will pick it up
            if (directions.length === 0) {
                stop()
                root._fail("Could not group Project Rend and Helium")
                return
            }
            HyprlandService.moveWindowIntoGroup(heliumAddress, directions[0])
            directions = directions.slice(1)
        }
    }

    // One split fix per tick, then the waiter re-reads the clients.
    Timer {
        id:       arrangeRetry
        interval: 600
        repeat:   true
        property string waydroidAddress: ""
        property int    attempts:        0
        onTriggered: {
            if (!root.launching || !root._waiter) {
                stop()
                return
            }
            let w = root._byAddress(waydroidAddress)
            let r = root._byAddress(root.rendAddress)
            if (!w || !r || root._tilesArranged(w, r)) return // the waiter will pick it up
            if (attempts <= 0) {
                stop()
                root._finishLayout() // couldn't arrange (e.g. extra windows); still resize
                return
            }
            attempts--
            HyprlandService.layoutMessageOn(waydroidAddress, "togglesplit")
        }
    }

    Timer {
        id:       sizeGrace
        interval: 2000
        onTriggered: {
            if (root.launching && root._waiter) root._done(`Waydroid width not ${root.waydroidWidth}`)
        }
    }

    Timer {
        id:       pollTimer
        interval: 500
        repeat:   true
        running:  root._waiter !== null
        onTriggered: clientsProcess.running = true
    }

    // Idle refresh of service state and window presence.
    Timer {
        interval:         3000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            statusProcess.running = true
            statusFile.reload() // in case the watch dropped when the daemon replaced the file
            if (root.logPart !== "") logFile.reload() // and when the log rotates
            if (!root._waiter) clientsProcess.running = true
        }
    }

    FileView {
        id:           logFile
        path:         root.logPart !== "" ? root._logPath(root.logPart) : ""
        watchChanges: true
        printErrors:  false
        onFileChanged: reload()
        onLoaded:      root._onLog(text())
        onLoadFailed:  root.logEntries = []
        onPathChanged: root.logEntries = []
    }

    // The daemon rewrites this atomically on every change.
    FileView {
        id:           statusFile
        path:         root.statusPath
        watchChanges: true
        printErrors:  false
        onFileChanged: reload()
        onLoaded:      root._onStatus(text())
    }

    // --- PROCESSES ---
    Process {
        id:      clientsProcess
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root._onClients(text)
        }
    }

    // Prints whatever is missing, one per line; empty output means all good.
    Process {
        id:      prereqProcess
        command: ["sh", "-c", "command -v waydroid >/dev/null || echo waydroid; [ -x \"$1\" ] || echo 'Project Rend AppImage'; [ -x \"$2\" ] || echo helium-safe-launch", "sh", root.rendPath, root.heliumLauncher]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.launching) return
                let missing = text.trim()
                if (missing !== "") root._fail("Missing " + missing.split("\n").join(", "))
                else if (root.mode === "fix") root._fixFromWaydroid()
                else root._startWaydroid()
            }
        }
    }

    Process {
        id:      statusProcess
        command: ["systemctl", "--user", "is-active", root.serviceName]
        stdout: StdioCollector {
            onStreamFinished: {
                let active = text.trim() === "active"
                // Only on a real change: the first check after a reload just learns the state.
                if (root._statusKnown && active !== root.daemonActive)
                    NotificationService.notify("The Tower", active ? "Service started" : "Service stopped", Assets.theTower, 1500, "", true)
                root.daemonActive = active
                root._statusKnown = true
            }
        }
    }

    property bool _statusKnown: false

    // Re-checks right away so the bar and the notification don't wait for the next poll.
    Process {
        id:        serviceToggle
        onExited:  root.refresh()
    }
}
