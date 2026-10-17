// components/bar/TheTower.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.components.menus
import qs.services.system
import qs.services.ui

Module {
    id: root

    property int    iconSize: Theme.iconSize
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamily

    ModuleItem {
        id: towerModule
        onClicked: (button) => {
            if (button === Qt.LeftButton) {
                TheTowerService.togglePart("run")
            } else if (button === Qt.RightButton) {
                towerMenu.open = !towerMenu.open
            }
        }

        IconLabel {
            id:        towerIcon
            icon:      Assets.hexagon
            // hexagon.svg is cropped to its edges, so it renders smaller to match the other bar icons.
            iconSize:  root.iconSize - 2
            colorize:  true
            iconColor: TheTowerService.scriptsEnabled || TheTowerService.launching ? ThemeState.accent : Theme.subtext

            Behavior on iconColor {
                ColorAnimation { duration: 200 }
            }

            // Pulses while launching or while a script is mid-action.
            SequentialAnimation on opacity {
                running: TheTowerService.launching || TheTowerService.scriptsBusy
                loops:   Animation.Infinite
                onRunningChanged: if (!running) towerIcon.opacity = 1.0
                NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
        }
    }

    TheTowerMenu {
        id:         towerMenu
        anchorItem: towerModule
    }
}
