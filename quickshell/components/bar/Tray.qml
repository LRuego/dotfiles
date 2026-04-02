// components/bar/Tray.qml
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.core
import qs.services.ui
import qs.components.base

Module {
    id: root

    // --- SCALE (set by Bar) ---
    // Tray is icon-only, so it exposes iconSize rather than textSize.
    property int iconSize: Theme.fontSizeLarge

    property var trayRules: []

    Component.onCompleted: {
        trayRules = [
            { match: "steam", icon: Assets.steam }
        ]
    }

    Repeater {
        model: SystemTray.items

        ModuleItem {
            id:           trayItem
            required property var modelData

            readonly property string resolvedIcon: {
                let itemId = trayItem.modelData.id.toLowerCase()
                for (let i = 0; i < trayRules.length; i++) {
                    if (itemId.includes(trayRules[i].match)) return trayRules[i].icon
                }
                return trayItem.modelData.icon
            }

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
                id:          trayMenu
                open:        false
                anchorItem:  trayItem
                menuHandle:  trayItem.modelData.menu
                menuWidth:   220
                onDismissed: trayMenu.open = false
            }

            IconLabel {
                icon:     trayItem.resolvedIcon
                colorize: false
                size:     root.iconSize
            }
        }
    }
}
