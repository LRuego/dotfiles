// components/bar/DateTime.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.components.popups
import qs.services.system

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    iconSize: Theme.fontSizeIcon
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamily

    ModuleItem {
        id: timeItem

        onClicked: (button) => {
            if (button === Qt.RightButton) timeContextMenu.open = !timeContextMenu.open
        }

        ContextMenu {
            id:         timeContextMenu
            anchorItem: timeItem
            model: [
                { text: "Copy Time", action: () => UtilService.copyToClipboard(ClockService.time) },
                { text: "Copy Date", action: () => UtilService.copyToClipboard(ClockService.date) }
            ]
        }

        IconLabel {
            labelBold: true
            icon:      Assets.clock
            iconSize:  root.iconSize
            colorize:  true
            text:      ClockService.time
            textFont:  root.textFont
            textSize:  root.textSize
        }
    }

    ModuleItem {
        id: calendarItem

        onClicked: (button) => {
            if (button === Qt.LeftButton)
                calendarPopup.open = !calendarPopup.open
        }

        IconLabel {
            labelBold: true
            icon:      Assets.calendar
            iconSize:  root.iconSize
            colorize:  true
            text:      ClockService.date
            textFont:  root.textFont
            textSize:  root.textSize
        }

        CalendarPopup {
            id:         calendarPopup
            anchorItem: calendarItem
        }
    }
}
