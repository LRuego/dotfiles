// components/bar/WindowTitle.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.components.base

Module {
    id: root

    ModuleItem {
        id: titleItem

        IconLabel {
            labelBold: true
            icon: Assets.hyprland
            iconSize: Theme.fontSize
            colorize: true

            text: Hyprland.activeToplevel?.title ?? "Desktop"
            textFont: Theme.fontFamilyAlt
            textSize: Theme.fontSizeSmall

            textWidth: 120
            elide: Text.ElideRight
        }
    }
}
