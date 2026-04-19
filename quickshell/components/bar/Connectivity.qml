// components/bar/Connectivity.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.components.popups
import qs.services.network
import qs.services.ui

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    iconSize: Theme.iconSize
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamily

    // --- HELPERS ---
    readonly property string netIcon: {
        if (NetworkService.statusText === "Eth") return Assets.networkWired
        if (NetworkService.statusText === "WiFi") {
            if (NetworkService.signal >= 75) return Assets.networkWiFiHigh
            if (NetworkService.signal >= 45) return Assets.networkWiFiMed
            return Assets.networkWiFiLow
        }
        return Assets.networkOff
    }

    readonly property color netColor: NetworkService.statusText === "Off" ? Theme.urgent : ThemeState.accent

    readonly property color btColor: {
        if (!BluetoothService.powered)   return Theme.subtext
        if (BluetoothService.connected)  return ThemeState.accent
        return ThemeState.text
    }

    ModuleItem {
        id: tsModule
        onClicked: (button) => {
            if (button === Qt.LeftButton) {
                TailscaleService.toggle()
            } else if (button === Qt.RightButton) {
                tsPopup.open = !tsPopup.open
            }
        }

        TailscalePopup {
            id:         tsPopup
            anchorItem: tsModule
        }

        IconLabel {
            id:       tsIcon
            icon:     TailscaleService.active ? Assets.tailscaleOn : Assets.tailscaleOff
            iconSize: 14

            SequentialAnimation on opacity {
                running: TailscaleService.transitioning
                loops:   Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
            onVisibleChanged: if (!TailscaleService.transitioning) opacity = 1.0
        }
    }

    ModuleItem {
        IconLabel {
            labelBold:  true
            icon:       root.netIcon
            iconColor:  root.netColor
            iconSize:   root.iconSize
            colorize:   true
            showText:   parent.hovered || BarState.peekMode
            text:       NetworkService.ssid
            textColor:  root.netColor
            textFont:   root.textFont
            textSize:   root.textSize
        }
    }

    ModuleItem {
        id: btItem
        onClicked: {
            if (BluetoothService.adapter) {
                BluetoothService.adapter.enabled = !BluetoothService.adapter.enabled
            }
        }

        IconLabel {
            labelBold: true
            icon:      BluetoothService.powered ? Assets.bluetooth : Assets.bluetoothOff
            iconColor: root.btColor
            iconSize:  root.iconSize
            colorize:  true
        }
    }
}
