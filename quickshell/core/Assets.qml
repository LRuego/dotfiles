// core/Assets.qml
pragma Singleton
import QtQuick

QtObject {
    function _resolve(path) {
        return Qt.resolvedUrl("../assets/" + path);
    }

    function get(name) {
        if (!name || name === "")
            return placeholder;
        if (name.startsWith("/") || name.startsWith("file://") || name.startsWith("http"))
            return name;
        if (/\.[a-zA-Z]+$/.test(name))
            return _resolve("icons/" + name);
        return _resolve("icons/" + name + ".svg");
    }

    // Icons from Phosphor Icons (https://phosphoricons.com) — MIT License

    // --- UTIL ---
    readonly property string placeholder:           _resolve("icons/placeholder-fill.svg")
    readonly property string packageIcon:           _resolve("icons/package-fill.svg")

    // --- UI ELEMENTS ---
    readonly property string reload:                _resolve("icons/arrows-clockwise-fill.svg")
    readonly property string caretDown:             _resolve("icons/caret-down-fill.svg")
    readonly property string caretLeft:             _resolve("icons/caret-left-fill.svg")
    readonly property string info:                  _resolve("icons/info.svg")
    readonly property string panelLeft:             _resolve("icons/panel-left.svg")
    readonly property string play:                  _resolve("icons/play.svg")
    readonly property string settings:              _resolve("icons/settings.svg")
    readonly property string flask:                 _resolve("icons/flask-conical.svg")

    // --- LOGOS / CUSTOM ---
    readonly property string quickshell:            _resolve("app/quickshell.svg")
    readonly property string hyprland:              _resolve("app/hyprland.svg")
    readonly property string steam:                 _resolve("app/steam.svg")
    readonly property string hexagon:               _resolve("app/hexagon.svg")
    readonly property string theTower:              _resolve("app/the_tower.png")
    readonly property string towerAutoRestart:      _resolve("icons/the_tower/auto-restart.svg")
    readonly property string towerGem:              _resolve("icons/the_tower/gem.svg")
    readonly property string tailscaleIcon:         _resolve("app/tailscale-icon.svg")
    readonly property string tailscaleOn:           _resolve("app/tailscale-on.svg")
    readonly property string tailscaleOff:          _resolve("app/tailscale-off.svg")

    // --- DEVICES ---
    readonly property string desktop:               _resolve("icons/devices/desktop.svg")
    readonly property string server:                _resolve("icons/devices/server.svg")
    readonly property string smartphone:            _resolve("icons/devices/device-mobile.svg")
    readonly property string mouse:                 _resolve("icons/devices/mouse.svg")
    readonly property string keyboard:              _resolve("icons/devices/keyboard.svg")
    readonly property string gamepad:               _resolve("icons/devices/gamepad.svg")
    readonly property string speaker:                _resolve("icons/devices/speaker.svg")
    readonly property string headphones:             _resolve("icons/devices/headphones.svg")
    readonly property string hardDrive:              _resolve("icons/devices/hard-drive.svg")
    readonly property string eject:                  _resolve("icons/devices/eject.svg")

    // --- DATE & TIME ---
    readonly property string clock:                 _resolve("icons/clock-fill.svg")
    readonly property string calendar:              _resolve("icons/calendar-dots-fill.svg")

    // --- AUDIO ---
    readonly property string volume:                _resolve("icons/speaker-none-fill.svg")
    readonly property string volumeMute:            _resolve("icons/speaker-slash-fill.svg")
    readonly property string volumeLow:             _resolve("icons/speaker-low-fill.svg")
    readonly property string volumeHigh:            _resolve("icons/speaker-high-fill.svg")
    readonly property string microphone:            _resolve("icons/microphone-fill.svg")
    readonly property string microphoneMute:        _resolve("icons/microphone-mute-fill.svg")

    // --- CONNECTIVITY ---
    readonly property string bluetooth:             _resolve("icons/bluetooth.svg")
    readonly property string bluetoothConnected:    _resolve("icons/bluetooth-connected.svg")
    readonly property string bluetoothOff:          _resolve("icons/bluetooth-slash.svg")
    readonly property string networkOff:            _resolve("icons/plugs-fill.svg")
    readonly property string networkWired:          _resolve("icons/network-wired-fill.svg")
    readonly property string networkWiFiHigh:       _resolve("icons/wifi-high-fill.svg")
    readonly property string networkWiFiMed:        _resolve("icons/wifi-medium-fill.svg")
    readonly property string networkWiFiLow:        _resolve("icons/wifi-low-fill.svg")
    readonly property string usb:                   _resolve("icons/devices/usb.svg")

    // --- SYSTEM RESOURCES ---
    readonly property string cpu:                   _resolve("icons/devices/cpu.svg")
    readonly property string ram:                   _resolve("icons/devices/memory.svg")
    readonly property string gpu:                   _resolve("icons/devices/gpu.svg")

    // --- NOTIFICATIONS ---
    readonly property string bell:                  _resolve("icons/bell-fill.svg")
    readonly property string bellRinging:           _resolve("icons/bell-ringing-fill.svg")
    readonly property string notificationFallback:  _resolve("icons/bell-ringing-fill.svg")
    readonly property string inbox:                 _resolve("icons/tray.svg")
}
