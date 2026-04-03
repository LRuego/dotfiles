// services/input/InputService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    // --- DEBUG ---
    readonly property bool debug: false

    // --- SIGNALS ---
    signal keyPressed(string key)
    signal keyReleased(string key)

    // --- MODIFIER STATE ---
    property int shiftCount: 0
    property int ctrlCount:  0
    property int altCount:   0
    property int superCount: 0

    readonly property bool shiftHeld: shiftCount > 0
    readonly property bool ctrlHeld:  ctrlCount > 0
    readonly property bool altHeld:   altCount > 0
    readonly property bool superHeld: superCount > 0

    // --- INTERNAL STATE ---
    property var holdTimers:     ({})
    property var keyHandlers:    ({})
    property var monitoredPaths: ({})
    property var activeWatchers: []
    property int keyboardCount:  0

    function refresh() {
        if (debug) console.log("[InputService] Refreshing keyboards...")

        for (let i = 0; i < activeWatchers.length; i++)
            activeWatchers[i].destroy()

        activeWatchers  = []
        monitoredPaths  = {}
        keyboardCount   = 0
        discoverProcess.restart()
    }

    // --- LOW LEVEL API ---

    function connectKey(key, onPress, onRelease) {
        if (!keyHandlers[key]) keyHandlers[key] = []
        keyHandlers[key].push({ onPress: onPress, onRelease: onRelease })
    }

    function disconnectKey(key) {
        delete keyHandlers[key]
        cancelHold(key)
    }

    // --- HOLD TIMER INTERNALS ---

    function startHold(key, interval, callback) {
        if (holdTimers[key]) holdTimers[key].destroy()
        let t = holdTimerComponent.createObject(root, {
            interval: interval,
            key: key,
            callback: callback
        })
        holdTimers[key] = t
        t.start()
    }

    function cancelHold(key) {
        if (holdTimers[key]) {
            holdTimers[key].stop()
            holdTimers[key].destroy()
            delete holdTimers[key]
        }
    }

    Component {
        id: holdTimerComponent
        Timer {
            property string key: ""
            property var callback: null
            repeat: false
            onTriggered: if (callback) callback()
        }
    }

    // --- PUBLIC API ---

    function onHold(key, interval, onHeld, onReleased) {
        let held = false
        connectKey(key,
            () => {
                startHold(key, interval, () => {
                    held = true
                    onHeld()
                })
            },
            () => {
                cancelHold(key)
                if (held) {
                    held = false
                    onReleased()
                }
            }
        )
    }

    function onTap(key, interval, callback) {
        connectKey(key,
            () => startHold(key, interval, null),
            () => {
                if (holdTimers[key]) {
                    cancelHold(key)
                    callback()
                }
            }
        )
    }

    function onTapAndHold(key, interval, callback, onHeld, onReleased) {
        let held = false
        connectKey(key,
            () => {
                startHold(key, interval, () => {
                    held = true
                    onHeld()
                })
            },
            () => {
                if (held) {
                    held = false
                    onReleased()
                } else {
                    cancelHold(key)
                    callback()
                }
            }
        )
    }

    function onToggle(key, onChange) {
        let state = false
        connectKey(key,
            () => {
                state = !state
                onChange(state)
            },
            null
        )
    }

    function onDoubleTap(key, interval, callback) {
        let lastTap = 0
        connectKey(key,
            null,
            () => {
                let now = Date.now()
                if (now - lastTap < interval) {
                    callback()
                    lastTap = 0
                } else {
                    lastTap = now
                }
            }
        )
    }

    // --- KEYBOARD DISCOVERY ---
    Process {
        id: discoverProcess
        command: [
            "bash", "-c",
            "grep -rH '' /sys/class/input/event*/device/name 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: line => {
                let parts = line.split(":")
                if (parts.length < 2) return
                let devSys = parts[0].replace("/device/name", "")
                let name = parts.slice(1).join(":")

                let isKeyboard = name.includes("Keyboard") &&
                                 !name.includes("Mouse") &&
                                 !name.includes("Consumer Control")

                if (isKeyboard) {
                    let path = devSys.replace("/sys/class/input/", "/dev/input/")
                    if (root.monitoredPaths[path]) return

                    if (debug) console.log("[InputService] Found keyboard:", path, "→", name)
                    let w = keyboardWatcher.createObject(root, { devicePath: path })
                    root.activeWatchers.push(w)
                    root.monitoredPaths[path] = true
                    root.keyboardCount++
                }
            }
        }

        onRunningChanged: {
            if (!running && debug)
                console.log("[InputService] Discovery complete —", root.keyboardCount, "keyboard devices found.")
        }
    }

    // --- PER-KEYBOARD WATCHER ---
    Component {
        id: keyboardWatcher
        Item {
            property string devicePath: ""
            property int    retryCount: 0
            readonly property int maxRetries:   5
            readonly property int retryDelayMs: 2000

            // Backoff timer — fires after retryDelayMs to restart evtest
            Timer {
                id: retryTimer
                interval: parent.retryDelayMs
                repeat:   false
                onTriggered: {
                    if (root.debug) console.log("[InputService] Retrying evtest for", devicePath, "(attempt", parent.retryCount + ")")
                    proc.running = true
                }
            }

            Process {
                id: proc
                command: ["evtest", devicePath]

                stderr: SplitParser {
                    onRead: line => console.log("[InputService] evtest error (" + devicePath + "):", line)
                }

                onExited: (code, status) => {
                    // Clean exit (code 0) means we killed it intentionally (e.g. refresh()), no retry needed
                    if (code === 0) return

                    console.log("[InputService] evtest exited with code " + code + " for " + devicePath)

                    if (retryCount >= maxRetries) {
                        console.log("[InputService] evtest for", devicePath, "failed", maxRetries, "times, giving up.")
                        return
                    }

                    retryCount++
                    retryTimer.start()
                }

                stdout: SplitParser {
                    onRead: line => {
                        let keyMatch = line.match(/KEY_\w+/)
                        if (!keyMatch) return
                        let key = keyMatch[0]

                        let valueMatch = line.match(/value (\d)/)
                        if (!valueMatch) return
                        let value = parseInt(valueMatch[1])

                        // --- UPDATE MODIFIER COUNTS ---
                        if (key === "KEY_LEFTSHIFT" || key === "KEY_RIGHTSHIFT") {
                            if (value === 1) root.shiftCount++
                            else if (value === 0) root.shiftCount = Math.max(0, root.shiftCount - 1)
                        }
                        if (key === "KEY_LEFTCTRL" || key === "KEY_RIGHTCTRL") {
                            if (value === 1) root.ctrlCount++
                            else if (value === 0) root.ctrlCount = Math.max(0, root.ctrlCount - 1)
                        }
                        if (key === "KEY_LEFTALT" || key === "KEY_RIGHTALT") {
                            if (value === 1) root.altCount++
                            else if (value === 0) root.altCount = Math.max(0, root.altCount - 1)
                        }
                        if (key === "KEY_LEFTMETA" || key === "KEY_RIGHTMETA") {
                            if (value === 1) root.superCount++
                            else if (value === 0) root.superCount = Math.max(0, root.superCount - 1)
                        }

                        // --- FIRE HANDLERS (ignore auto-repeat) ---
                        if (value === 1) {
                            root.keyPressed(key)
                            if (root.keyHandlers[key])
                                root.keyHandlers[key].forEach(h => h.onPress && h.onPress())
                        } else if (value === 0) {
                            root.keyReleased(key)
                            if (root.keyHandlers[key])
                                root.keyHandlers[key].forEach(h => h.onRelease && h.onRelease())
                        }
                        // value 2 (auto-repeat) intentionally ignored
                    }
                }
            }

            Component.onCompleted: proc.running = true

            Connections {
                target: proc
                function onRunningChanged() {
                    if (proc.running) retryCount = 0
                }
            }
        }
    }

    Component.onCompleted: {
        if (debug) console.log("[InputService] Starting keyboard discovery...")
        discoverProcess.running = true
    }
}
