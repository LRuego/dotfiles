pragma Singleton
import QtQuick

QtObject {
    // Helper function to resolve paths relative to the assets folder
    function asset(name) {
        return Qt.resolvedUrl("../assets/" + name);
    }

    // --- Date & Time ---
    readonly property string clock:  asset("clock.svg")
    readonly property string calendar:  asset("calendar.svg")

    // --- Audio ---
    readonly property string volume:  asset("volume.svg")
    readonly property string volumeMute:  asset("volume-mute.svg")
    readonly property string volumeDown:  asset("volume-down.svg")
    readonly property string volumeUp:  asset("volume-up.svg")
    readonly property string microphone:  asset("microphone.svg")
    readonly property string microphoneMute:  asset("microphone-mute.svg")

    // --- Connectivity ---
    readonly property string bluetooth : asset("bluetooth.svg")
    readonly property string bluetoothOff : asset("bluetooth-disconnected.svg")
    readonly property string networkOff: asset("disconnected.svg")
    readonly property string networkWired: asset("network-wired.svg")
    readonly property string networkWireless: asset("wifi.svg")
    readonly property string tailscaleOn:  asset("tailscale-on.svg")
    readonly property string tailscaleOff: asset("tailscale-off.svg")

    // --- Utility ---
    // Allows calling Assets.get("any-file-name") for files not defined above
    function get(name) {
        return asset(name + (name.includes(".") ? "" : ".svg"));
    }
}
