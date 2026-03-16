// components/bar/SystemResources.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

    property int    textSize:     Theme.fontSizeSmall
    property string textFont:     Theme.fontFamilyAlt

    ModuleItem {
        id: cpuItem

        IconLabel {
            labelBold: true
            icon: Assets.cpu
            iconColor: ResourceService.cpuUsage >= 90 ? Theme.urgent : (ResourceService.cpuUsage >= 75 ? Theme.warning : Theme.text)
            colorize: true
            iconSize: Theme.fontSize

            text: ResourceService.cpuUsage + "%"
            textColor: iconColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: ResourceService.cpuUsage < 100 ? 24 : 32
        }
    }

    ModuleItem {
        id: memItem
        // Hidden unless CPU or itself is hovered
        isHidden: !(cpuItem.hovered || hovered)

        IconLabel {
            labelBold: true
            icon: Assets.ram
            iconColor: ResourceService.memUsagePercent >= 90 ? Theme.urgent : (ResourceService.memUsagePercent >= 75 ? Theme.warning : Theme.text)
            colorize: true
            iconSize: Theme.fontSize

            text: ResourceService.memUsagePercent + "%"
            textColor: iconColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: ResourceService.memUsagePercent < 100 ? 24 : 32
        }
    }
}
