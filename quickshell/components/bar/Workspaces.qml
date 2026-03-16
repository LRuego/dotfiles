import QtQuick
import QtQuick.Effects
import Quickshell
import "../../core"
import "../../services"
import "../base"

Module {
    id: root

    // --- CONFIGURATION ---
    property bool   enclosed:       true
    property string indicatorStyle: "pills" // "pills" | "circles" | "numbers"

    baseColor:   root.enclosed ? Theme.surface0 : "transparent"
    borderColor: root.enclosed ? Theme.overlay  : "transparent"
    hoverColor:  root.enclosed ? Theme.surface1 : "transparent"

    Item {
        id: shapesContainer
        visible: root.indicatorStyle !== "numbers"
        width: visible ? (shapeRow.width + (root.enclosed ? 24 : 0)) : 0
        height: parent.height

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) HyprlandService.prevWorkspace()
                else HyprlandService.nextWorkspace()
            }
        }

        Row {
            id: shapeRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: root.indicatorStyle !== "numbers" ? HyprlandService.workspaces : 0

                Item {
                    id: shapeWsItem
                    visible: modelData.id >= 0

                    readonly property bool isFocused: modelData.active
                    readonly property bool isHovered: mouseArea.containsMouse

                    width: root.indicatorStyle === "pills" ? (isFocused ? 32 : (isHovered ? 20 : 12)) : (root.indicatorStyle === "circles" ? 10 : 12)
                    height: root.indicatorStyle === "circles" ? 10 : 6
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

                    Rectangle {
                        id: shapeIndicator
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: height / 2

                        color: (shapeWsItem.isFocused || shapeWsItem.isHovered) ? Theme.primary : Theme.surface1

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MultiEffect {
                        source: shapeIndicator
                        anchors.fill: shapeIndicator
                        visible: shapeWsItem.isFocused
                        shadowEnabled: true
                        shadowColor: Theme.primary
                        shadowBlur: 0.8
                        shadowScale: 1.2
                        opacity: 0.7
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: HyprlandService.goToWorkspace(modelData.id)
                        onWheel: (wheel) => {
                            if (wheel.angleDelta.y > 0) HyprlandService.prevWorkspace()
                            else HyprlandService.nextWorkspace()
                        }
                    }
                }
            }
        }
    }

    Repeater {
        model: root.indicatorStyle === "numbers" ? HyprlandService.workspaces : 0

        ModuleItem {
            id: numberItem
            visible: modelData.id >= 0

            readonly property bool isFocused: modelData.active

            onClicked: (button) => HyprlandService.goToWorkspace(modelData.id)
            onWheeled: (isUp) => {
                if (isUp) HyprlandService.prevWorkspace()
                else HyprlandService.nextWorkspace()
            }

            Text {
                text: modelData.id
                color: numberItem.isFocused ? Theme.primary : (numberItem.hovered ? Theme.surface2 : Theme.text)
                font.family: Theme.fontFamilyAlt
                font.pixelSize: Theme.fontSizeSmall
                font.bold: numberItem.isFocused

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
