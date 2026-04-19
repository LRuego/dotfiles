// components/bar/Notifications.qml
import QtQuick
import qs.core
import qs.services.ui
import qs.components.base

Module {
    id: root

    // --- SCALE (set by Bar) ---
    // Notifications is icon-only, so it exposes iconSize rather than textSize.
    property int iconSize: Theme.iconSize

    ModuleItem {
        onClicked: NotificationService.centerVisible = !NotificationService.centerVisible

        Item {
            implicitWidth:  iconLabel.implicitWidth
            implicitHeight: iconLabel.implicitHeight

            IconLabel {
                id:        iconLabel
                icon:      Assets.bell
                colorize:  true
                iconColor: NotificationService.dnd ? Theme.subtext : ThemeState.text
                size:      root.iconSize
            }

            Rectangle {
                visible:             NotificationService.unreadCount > 0 && !NotificationService.dnd
                width:               6
                height:              6
                radius:              3
                color:               Theme.urgent
                anchors.top:         iconLabel.top
                anchors.right:       iconLabel.right
                anchors.topMargin:   -1
                anchors.rightMargin: -3
            }
        }
    }
}
