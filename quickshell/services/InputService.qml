// services/InputService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

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
    property var holdTimers:    ({})
    property var keyHandlers:   ({})
    property int keyboardCount: 0

    // --- LOW LEVEL API ---

    function connectKey(key, onPress, onRelease) {
        keyHandlers[key] = { onPress: onPress, onRelease: onRelease }
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

    function onTap(key, interval, onTap) {
        connectKey(key,
            () => startHold(key, interval, null),
            () => {
                if (holdTimers[key]) {
                    cancelHold(key)
                    onTap()
                }
            }
        )
    }

    function onTapAndHold(key, interval, onTap, onHeld, onReleased) {
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
                    onTap()
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

    function onDoubleTap(key, interval, onDoubleTap) {
        let lastTap = 0
        connectKey(key,
            null,  // nothing on press
            () => {  // fire on release
                let now = Date.now()
                if (now - lastTap < interval) {
                    onDoubleTap()
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
                    // --- DEBUG ---
                    // console.log("[InputService] Found keyboard:", path, "→", name)
                    keyboardWatcher.createObject(root, { devicePath: path })
                    root.keyboardCount++
                }
            }
        }
        onRunningChanged: {
            if (!running)
                console.log("[InputService] Discovery complete —", root.keyboardCount, "keyboard devices found.")
        }
    }

    // --- PER-KEYBOARD WATCHER ---

    Component {
        id: keyboardWatcher
        Item {
            property string devicePath: ""

            Process {
                id: proc
                running: false
                command: ["evtest", devicePath]

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
                            if (root.keyHandlers[key]?.onPress)
                                root.keyHandlers[key].onPress()
                        } else if (value === 0) {
                            root.keyReleased(key)
                            if (root.keyHandlers[key]?.onRelease)
                                root.keyHandlers[key].onRelease()
                        }
                        // value 2 (auto-repeat) intentionally ignored
                    }
                }
            }

            Component.onCompleted: proc.running = true
        }
    }

    Component.onCompleted: {
        console.log("[InputService] Starting keyboard discovery...")
        discoverProcess.running = true
    }
}
