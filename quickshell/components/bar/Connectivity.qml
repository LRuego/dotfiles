// components/bar/Connectivity.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

    // --- HELPERS ---
    readonly property string netIcon: {
        if (NetworkService.statusText === "Eth") return Assets.networkWired
        if (NetworkService.statusText === "WiFi") return Assets.networkWireless
        return Assets.networkOff
    }

    readonly property color netColor: NetworkService.statusText === "Off" ? Theme.urgent : ThemeState.accent

    readonly property color btColor: {
        if (!BluetoothService.powered) return Theme.subtext
        if (BluetoothService.connected) return ThemeState.accent
        return Theme.text
    }

    ModuleItem {
        id: tsModule
        onClicked: (button) => {
            if (button === Qt.RightButton) {
                TailscaleService.openMenu(tsModule)
            } else {
                TailscaleService.toggle()
            }
        }

        IconLabel {
            id: tsIcon
            icon: TailscaleService.active ? Assets.tailscaleOn : Assets.tailscaleOff
            colorize: true

            SequentialAnimation on opacity {
                running: TailscaleService.transitioning
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
            onVisibleChanged: if (!TailscaleService.transitioning) opacity = 1.0
        }
    }

    ModuleItem {
        IconLabel {
            labelBold: true
            icon:      root.netIcon
            iconColor: root.netColor
            colorize:  true
            iconWidth: Theme.fontSize
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
            colorize:  true
        }
    }
}
