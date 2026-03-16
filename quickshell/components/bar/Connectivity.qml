// components/bar/Connectivity.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

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
            icon: TailscaleService.icon
            colorize: false

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
            icon: NetworkService.icon
            iconColor: NetworkService.statusColor
            colorize: true
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
            icon: BluetoothService.icon
            iconColor: BluetoothService.statusColor
            colorize: true
        }
    }
}
