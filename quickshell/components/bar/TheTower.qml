// components/bar/TheTower.qml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.components.base
import qs.components.popups
import qs.services.ui

Module {
    id: root

    property int    iconSize: Theme.iconSize
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamily

    property bool isActive: false

    Process {
        id: statusProcess
        command: ["bash", "-c", "systemctl --user is-active the-tower-auto-run.service || echo inactive"]
        stdout: SplitParser {
            onRead: data => {
                root.isActive = (data.trim() === "active")
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["bash", "-c", "if systemctl --user is-active --quiet the-tower-auto-run.service; then systemctl --user stop the-tower-auto-run.service; echo stopped; else systemctl --user start the-tower-auto-run.service; echo started; fi; systemctl --user is-active the-tower-auto-run.service || echo inactive"]
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim()
                if (trimmed === "started") {
                    NotificationService.notify("The Tower", "Service started", Assets.theTower, 1500, "", true)
                } else if (trimmed === "stopped") {
                    NotificationService.notify("The Tower", "Service stopped", Assets.theTower, 1500, "", true)
                } else if (trimmed === "active" || trimmed === "inactive") {
                    root.isActive = (trimmed === "active")
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

    ModuleItem {
        id: towerModule
        onClicked: (button) => {
            if (button === Qt.LeftButton) {
                toggleProcess.running = true
            } else if (button === Qt.RightButton) {
                towerPopup.open = !towerPopup.open
            }
        }

        IconLabel {
            icon:      Assets.hexagon
            iconSize:  root.iconSize
            colorize:  true
            iconColor: root.isActive ? ThemeState.accent : Theme.subtext

            Behavior on iconColor {
                ColorAnimation { duration: 200 }
            }
        }
    }

    TheTowerPopup {
        id: towerPopup
        anchorItem: towerModule
    }
}
