// components/bar/SystemResources.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.services.input
import qs.services.system
import qs.services.ui

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    iconSize: Theme.fontSizeLarge
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    // --- DISPLAY HELPERS ---
    readonly property string cpuDisplay:  InputService.shiftHeld ? ResourceService.cpuTemp + "°C" : ResourceService.cpuUsage + "%"
    readonly property string memDisplay:  ResourceService.memUsageGiB + "G"
    readonly property string gpuDisplay:  InputService.shiftHeld ? ResourceService.gpuTemp + "°C" : ResourceService.gpuUsage + "%"
    readonly property string vramDisplay: ResourceService.vramUsageGiB + "G"

    // --- COLOR HELPERS ---
    function usageColor(usage, temp) {
        if (usage >= 90 || temp >= 80) return Theme.urgent
        if (usage >= 75 || temp >= 70) return Theme.warning
        return ThemeState.text
    }

    function memColor(percent) {
        if (percent >= 90) return Theme.urgent
        if (percent >= 75) return Theme.warning
        return ThemeState.text
    }

    ModuleItem {
        id: cpuItem
        IconLabel {
            labelBold:  true
            icon:       Assets.cpu
            iconColor:  root.usageColor(ResourceService.cpuUsage, ResourceService.cpuTemp)
            iconSize:   root.iconSize
            colorize:   true

            text:       root.cpuDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textWidth:  root.cpuDisplay.length <= 3 ? 24 : 32
            textSize:   root.textSize
        }
    }

    ModuleItem {
        id: memItem
        isHidden: !(cpuItem.hovered || hovered || BarState.peekMode || BarState.gamingMode)
        IconLabel {
            labelBold:  true
            icon:       Assets.ram
            iconColor:  root.memColor(ResourceService.memUsagePercent)
            iconSize:   root.iconSize
            colorize:   true

            text:       root.memDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textWidth:  root.memDisplay.length <= 2 ? 16 : root.memDisplay.length <= 4 ? 32 : 40
            textSize:   root.textSize
        }
    }

    ModuleItem {
        id: gpuItem
        isHidden: !(BarState.gamingMode || BarState.peekMode)
        IconLabel {
            labelBold:  true
            icon:       Assets.gpu
            iconColor:  root.usageColor(ResourceService.gpuUsage, ResourceService.gpuTemp)
            iconSize:   root.iconSize
            colorize:   true

            text:       root.gpuDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textWidth:  root.gpuDisplay.length <= 3 ? 24 : 32
            textSize:   root.textSize
        }
    }

    ModuleItem {
        id: vramItem
        isHidden: !(BarState.gamingMode || BarState.peekMode) || !(gpuItem.hovered || hovered || BarState.peekMode || BarState.gamingMode)
        IconLabel {
            labelBold:  true
            icon:       Assets.ram
            iconColor:  root.memColor(ResourceService.vramUsagePercent)
            iconSize:   root.iconSize
            colorize:   true

            text:       root.vramDisplay
            textColor:  iconColor
            textFont:   root.textFont
            textWidth:  root.vramDisplay.length <= 2 ? 16 : root.vramDisplay.length <= 4 ? 32 : 40
            textSize:   root.textSize
        }
    }
}
