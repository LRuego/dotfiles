// components/bar/DateTime.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.services.system

Module {
    id: root

    property int    textSize:     Theme.fontSizeSmall
    property string textFont:     Theme.fontFamilyAlt

    ModuleItem {
        onClicked: console.log("Time Clicked!")
        IconLabel {
            labelBold:    true
            icon:         Assets.clock
            iconSize:     root.textSize
            colorize:     true
            text:         ClockService.time
            textFont:     root.textFont
            textSize:     root.textSize
        }
    }
    ModuleItem {
        id: calendarItem
        onClicked: (button) => {
            if (typeof sampleMenu !== "undefined") {
                sampleMenu.anchorItem = calendarItem
                sampleMenu.open = !sampleMenu.open
            }
        }
        IconLabel {
            labelBold:    true
            icon:         Assets.calendar
            iconSize:     Theme.fontSizeTiny
            colorize:     true
            text:         ClockService.date
            textFont:     root.textFont
            textSize:     root.textSize
        }
    }
}
