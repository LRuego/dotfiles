pragma Singleton
import QtQuick
import "."

QtObject {
    function asset(path) {
        return Qt.resolvedUrl("../assets/" + path);
    }

    // --- Logos ---
    readonly property string quickshell: asset("system/quickshell.svg")
    readonly property string hyprland: asset("system/hyprland.svg")
    readonly property string notificationFallback: asset("system/notification-fallback.svg")

    // --- Devices ---
    readonly property string desktop: asset("system/device-desktop.svg")
    readonly property string server: asset("system/device-server.svg")
    readonly property string smartphone: asset("system/device-smartphone.svg")

    // --- Date & Time ---
    readonly property string clock:  asset("system/clock.svg")
    readonly property string calendar:  asset("system/calendar.svg")

    // --- Audio ---
    readonly property string volume:  asset("system/volume.svg")
    readonly property string volumeMute:  asset("system/volume-mute.svg")
    readonly property string volumeDown:  asset("system/volume-down.svg")
    readonly property string volumeUp:  asset("system/volume-up.svg")
    readonly property string microphone:  asset("system/microphone.svg")
    readonly property string microphoneMute:  asset("system/microphone-mute.svg")

    // --- Connectivity ---
    readonly property string bluetooth : asset("system/bluetooth.svg")
    readonly property string bluetoothOff : asset("system/bluetooth-disconnected.svg")
    readonly property string networkOff: asset("system/disconnected.svg")
    readonly property string networkWired: asset("system/network-wired.svg")
    readonly property string networkWireless: asset("system/wifi.svg")
    readonly property string tailscaleIcon:  asset("system/tailscale-icon.svg")
    readonly property string tailscaleOn:  asset("system/tailscale-on.svg")
    readonly property string tailscaleOff: asset("system/tailscale-off.svg")

    // --- System Resources ---
    readonly property string cpu: asset("system/cpu.svg")
    readonly property string ram: asset("system/ram.svg")

    function get(name) {
        // Fallback search logic: try system/ first, then root
        return asset("system/" + name + (name.includes(".") ? "" : ".svg"));
    }
}
