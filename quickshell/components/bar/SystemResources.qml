// components/bar/SystemResources.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    // --- DISPLAY HELPERS ---
    readonly property string cpuDisplay:  InputService.shiftHeld ? ResourceService.cpuTemp + "°C" : ResourceService.cpuUsage + "%"
    readonly property string memDisplay:  ResourceService.memUsagePercent + "%"
    readonly property string gpuDisplay:  InputService.shiftHeld ? ResourceService.gpuTemp + "°C" : ResourceService.gpuUsage + "%"
    readonly property string vramDisplay: ResourceService.vramUsagePercent + "%"

    // --- COLOR HELPERS ---
    function usageColor(usage, temp) {
        if (usage >= 90 || temp >= 80) return Theme.urgent
        if (usage >= 75 || temp >= 70) return Theme.warning
        return Theme.text
    }

    function memColor(percent) {
        if (percent >= 90) return Theme.urgent
        if (percent >= 75) return Theme.warning
        return Theme.text
    }

    ModuleItem {
        id: cpuItem
        IconLabel {
            labelBold:  true
            icon:       Assets.cpu
            iconColor:  root.usageColor(ResourceService.cpuUsage, ResourceService.cpuTemp)
            colorize:   true
            iconSize:   Theme.fontSize
            text:       root.cpuDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  root.cpuDisplay.length <= 3 ? 24 : 32
        }
    }

    ModuleItem {
        id: memItem
        isHidden: !(cpuItem.hovered || hovered || BarState.peekMode || BarState.gamingMode)
        IconLabel {
            labelBold:  true
            icon:       Assets.ram
            iconColor:  root.memColor(ResourceService.memUsagePercent)
            colorize:   true
            iconSize:   Theme.fontSize
            text:       root.memDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  root.memDisplay.length <= 3 ? 24 : 32
        }
    }

    ModuleItem {
        id: gpuItem
        property bool shouldShow: BarState.gamingMode || BarState.peekMode
        isHidden: !shouldShow
        IconLabel {
            labelBold:  true
            icon:       Assets.gpu
            iconColor:  root.usageColor(ResourceService.gpuUsage, ResourceService.gpuTemp)
            colorize:   true
            iconSize:   Theme.fontSize
            text:       root.gpuDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  root.gpuDisplay.length <= 3 ? 24 : 32
        }
    }

    ModuleItem {
        id: vramItem
        property bool gamemodeVisible: BarState.gamingMode || BarState.peekMode
        property bool shouldShow:      gpuItem.hovered || hovered || BarState.peekMode || BarState.gamingMode
        isHidden: !gamemodeVisible || !shouldShow
        IconLabel {
            labelBold:  true
            icon:       Assets.ram
            iconColor:  root.memColor(ResourceService.vramUsagePercent)
            colorize:   true
            iconSize:   Theme.fontSize
            text:       root.vramDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  root.vramDisplay.length <= 3 ? 24 : 32
        }
    }
}
