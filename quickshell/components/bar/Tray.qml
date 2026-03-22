// components/bar/Tray.qml
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.core
import qs.services.ui
import qs.components.base

Module {
    id: root

    Repeater {
        model: SystemTray.items

        ModuleItem {
            id:           trayItem
            required property var modelData

            onClicked: (button) => {
                if (button === Qt.RightButton && trayItem.modelData.hasMenu) {
                    trayMenu.open = !trayMenu.open
                } else if (button === Qt.LeftButton && !trayItem.modelData.onlyMenu) {
                    trayItem.modelData.activate()
                } else if (trayItem.modelData.hasMenu) {
                    trayMenu.open = !trayMenu.open
                }
            }

            onWheeled: (isUp) => trayItem.modelData.scroll(isUp ? 1 : -1, false)

            ContextMenu {
                id:         trayMenu
                open:       false
                anchorItem: trayItem
                menuHandle: trayItem.modelData.menu
                menuWidth:  220
                onDismissed: trayMenu.open = false
            }

            IconLabel {
                icon:     trayItem.modelData.icon
                iconSize: Theme.fontSizeSmall
            }
        }
    }
}
