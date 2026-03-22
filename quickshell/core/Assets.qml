// core/Assets.qml
pragma Singleton
import QtQuick

QtObject {
    function asset(path) {
        return Qt.resolvedUrl("../assets/" + path);
    }

    // --- LOGOS ---
    readonly property string quickshell:            asset("app/quickshell.svg")
    readonly property string hyprland:              asset("app/hyprland.svg")
    readonly property string hamr:                  asset("app/hamr.png")
    readonly property string notificationFallback:  asset("ui/notification-fallback.svg")
    readonly property string steam:                 asset("app/steam.svg")

    // --- DEVICES ---
    readonly property string desktop:               asset("system/device-desktop.svg")
    readonly property string server:                asset("system/device-server.svg")
    readonly property string smartphone:            asset("system/device-smartphone.svg")

    // --- DATE & TIME ---
    readonly property string clock:                 asset("ui/clock.svg")
    readonly property string calendar:              asset("ui/calendar.svg")

    // --- AUDIO ---
    readonly property string volume:                asset("ui/volume.svg")
    readonly property string volumeMute:            asset("ui/volume-mute.svg")
    readonly property string volumeDown:            asset("ui/volume-down.svg")
    readonly property string volumeUp:              asset("ui/volume-up.svg")
    readonly property string microphone:            asset("ui/microphone.svg")
    readonly property string microphoneMute:        asset("ui/microphone-mute.svg")

    // --- CONNECTIVITY ---
    readonly property string bluetooth:             asset("system/bluetooth.svg")
    readonly property string bluetoothOff:          asset("system/bluetooth-disconnected.svg")
    readonly property string networkOff:            asset("system/disconnected.svg")
    readonly property string networkWired:          asset("system/network-wired.svg")
    readonly property string networkWireless:       asset("system/wifi.svg")
    readonly property string tailscaleIcon:         asset("app/tailscale-icon.svg")
    readonly property string tailscaleOn:           asset("app/tailscale-on.svg")
    readonly property string tailscaleOff:          asset("app/tailscale-off.svg")

    // --- SYSTEM RESOURCES ---
    readonly property string cpu:                   asset("system/cpu.svg")
    readonly property string ram:                   asset("system/ram.svg")
    readonly property string gpu:                   asset("system/gpu.svg")

    // --- NOTIFICATIONS ---
    readonly property string inbox:                 asset("ui/inbox.svg")

    function get(name) {
        // Fallback search logic: try system/ first, then app/, then ui/
        return asset("system/" + name + (name.includes(".") ? "" : ".svg"));
    }
}
