// widgets/Workspaces.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "../theme.js" as Theme

Row {
    id: root
    spacing:                      10

    Repeater {
        model:                    Hyprland.workspaces

        Item {
            visible:              modelData.id >= 0
            width:                modelData.focused ? 48 : 24
            height:               8

            Rectangle {
                id:               barRect
                anchors.fill:     parent
                radius:           4
                color:            (modelData && modelData.active) ? Theme.primary : Theme.surface1

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:    Hyprland.dispatch("workspace " + modelData.id)
                }
            }

            MultiEffect {
                source:           barRect
                anchors.fill:     barRect
                shadowEnabled:    true
                shadowColor:      barRect.color
                shadowBlur:       0.8
                shadowScale:      1.2
                opacity:          0.7
            }
        }
    }
}
