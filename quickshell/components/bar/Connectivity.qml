// components/bar/Connectivity.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.components.menus
import qs.services.network
import qs.services.ui
import qs.services.system

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

        TailscaleMenu {
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
        id: netItem
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
        onClicked: (button) => {
            if (button === Qt.LeftButton) {
                BluetoothService.togglePower()
            } else if (button === Qt.RightButton) {
                btPopup.open = !btPopup.open
            }
        }

        BluetoothMenu {
            id:         btPopup
            anchorItem: btItem
        }

        IconLabel {
            labelBold: true
            icon:      BluetoothService.powered ? Assets.bluetooth : Assets.bluetoothOff
            iconColor: root.btColor
            iconSize:  root.iconSize
            colorize:  true
        }
    }

    ModuleItem {
        id: usbModule
        isHidden: !(UsbService.storageDevices.length > 0 || BarState.peekMode || usbMenu.open)
        onClicked: usbMenu.open = !usbMenu.open

        UsbMenu {
            id:         usbMenu
            anchorItem: usbModule
        }

        IconLabel {
            icon:       Assets.usb
            iconColor:  Theme.subtext
            iconSize:   root.iconSize
            colorize:   true
        }
    }
}
