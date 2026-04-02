// components/bar/WindowTitle.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.components.base

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    ModuleItem {
        id: titleItem

        IconLabel {
            labelBold: true
            icon:      Assets.hyprland
            colorize:  true
            text:      Hyprland.activeToplevel?.title ?? "Desktop"
            textWidth: 120
            elide:     Text.ElideRight
            textFont:  root.textFont
            size:      root.textSize
        }
    }
}
