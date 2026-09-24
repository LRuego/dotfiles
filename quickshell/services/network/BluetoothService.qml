// services/network/BluetoothService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.core

QtObject {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- ADAPTER RESOLUTION ---
    readonly property var _adapters: Bluetooth.adapters.values
    readonly property var adapter: Bluetooth.defaultAdapter ?? (_adapters.length > 0 ? _adapters[0] : null)

    // --- STATE ---
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property bool discovering: adapter ? adapter.discovering : false

    readonly property var devices: adapter ? adapter.devices.values : []

    // Bonded devices persist via bluez's own pairing store — that's the "saved devices" list.
    readonly property var savedDevices: devices.filter(d => d.bonded)

    // Discovered but not paired yet — candidates for "connect a new device".
    readonly property var availableDevices: devices.filter(d => !d.bonded && d.name && d.name !== "")

    readonly property bool connected: {
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected) return true
        }
        return false
    }

    // --- ACTIONS ---
    function togglePower() {
        if (adapter) adapter.enabled = !adapter.enabled
    }

    function startDiscovery() {
        if (adapter && adapter.enabled) adapter.discovering = true
    }

    function stopDiscovery() {
        if (adapter) adapter.discovering = false
    }

    // --- ICON MAPPING ---
    // bluez hints a freedesktop icon name (e.g. "audio-headset") — map it to our own icon set.
    function deviceIcon(device) {
        let hint = (device && device.icon) ? device.icon : ""
        if (hint.indexOf("headset") !== -1 || hint.indexOf("headphone") !== -1)
            return Assets.headphones
        if (hint.indexOf("audio-card") !== -1 || hint.indexOf("speaker") !== -1)
            return Assets.speaker
        if (hint.indexOf("input-mouse") !== -1)
            return Assets.mouse
        if (hint.indexOf("input-keyboard") !== -1)
            return Assets.keyboard
        if (hint.indexOf("input-gaming") !== -1 || hint.indexOf("joystick") !== -1)
            return Assets.gamepad
        if (hint.indexOf("phone") !== -1)
            return Assets.smartphone
        if (hint.indexOf("computer") !== -1)
            return Assets.desktop
        return Assets.bluetooth
    }
}
