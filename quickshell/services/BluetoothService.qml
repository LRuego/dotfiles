// services/BluetoothService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../core"

QtObject {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- ADAPTER RESOLUTION ---
    readonly property var _adapters: Bluetooth.adapters.values
    readonly property var adapter: Bluetooth.defaultAdapter ?? (_adapters.length > 0 ? _adapters[0] : null)

    // --- STATE ---
    readonly property bool powered: adapter ? adapter.enabled : false

    readonly property bool connected: {
        if (!adapter) return false
        let devs = Bluetooth.devices ? Bluetooth.devices.values : (adapter.devices ? adapter.devices.values : [])

        for (let i = 0; i < devs.length; i++) {
            if (devs[i].connected) return true
        }
        return false
    }

    // --- UI HELPERS ---
    readonly property string icon: {
        if (!powered) return Assets.bluetoothOff
        if (connected) return Assets.bluetooth
        return Assets.bluetooth
    }

    readonly property color statusColor: {
        if (!powered) return Theme.subtext
        if (connected) return Theme.primary
        return Theme.text
    }

    readonly property string statusText: powered ? "On" : "Off"
}
