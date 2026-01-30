import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../theme.js" as Theme

QtObject {
    id: root

    // --- CONFIG ---
    property bool debug: false

    // --- ADAPTER RESOLUTION ---
    readonly property var _adapters: Bluetooth.adapters.values
    readonly property var adapter: Bluetooth.defaultAdapter ?? (_adapters.length > 0 ? _adapters[0] : null)

    //  --  BLUETOOTH LOGGING ---
    Component.onCompleted: {
        if (root.debug) {
            console.log("[BT] Service Loaded")
            console.log("[BT] Selected Adapter:", adapter)
            if (adapter) {
                console.log("[BT] Props - Enabled:", adapter.enabled)
                console.log("[BT] Props - Devices:", adapter.devices ? adapter.devices.values.length : "null")
            }
        }
    }

    // --- STATE ---
    // Use 'enabled' as confirmed by logs
    readonly property bool powered: adapter ? adapter.enabled : false

    // Check devices
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
        if (!powered) return "󰂲" // Disabled/Off
        if (connected) return "󰂯" // Connected
        return "󰂯" // On but disconnected
    }

    readonly property color statusColor: {
        if (!powered) return Theme.subtext
        if (connected) return Theme.primary // Blue
        return Theme.text // White
    }

    readonly property string statusText: powered ? "On" : "Off"
}
