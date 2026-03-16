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
            icon: ResourceService.cpuIcon
            iconColor: ResourceService.cpuUsage >= 90 || ResourceService.cpuTemp >= 80 ? Theme.urgent : (ResourceService.cpuUsage >= 75 || ResourceService.cpuTemp >= 70 ? Theme.warning : Theme.text)
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
            icon: ResourceService.memIcon
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

    ModuleItem {
        id: gpuItem
        // GAMING MODE: Only show if Feral GameMode is active
        isHidden: !ResourceService.gamemodeActive

        IconLabel {
            labelBold: true
            icon: ResourceService.gpuIcon
            iconColor: ResourceService.gpuUsage >= 90 || ResourceService.gpuTemp >= 80 ? Theme.urgent : (ResourceService.gpuUsage >= 75 || ResourceService.gpuTemp >= 70 ? Theme.warning : Theme.text)
            colorize: true
            iconSize: Theme.fontSize

            text: ResourceService.gpuUsage + "%"
            textColor: iconColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: 32
        }
    }

    ModuleItem {
        id: vramItem
        // Hidden unless GPU is visible and either GPU or itself is hovered
        isHidden: gpuItem.isHidden || !(gpuItem.hovered || hovered)

        IconLabel {
            labelBold: true
            icon: ResourceService.vramIcon
            iconColor: ResourceService.vramUsagePercent >= 90 ? Theme.urgent : (ResourceService.vramUsagePercent >= 75 ? Theme.warning : Theme.text)
            colorize: true
            iconSize: Theme.fontSize

            text: ResourceService.vramUsagePercent + "%"
            textColor: iconColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: ResourceService.vramUsagePercent < 100 ? 24 : 32
        }
    }
}
