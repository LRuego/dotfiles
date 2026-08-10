// components/bar/Workspaces.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.services.system
import qs.services.ui
import qs.components.base

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    // --- SCREEN (passed from Bar) ---
    property var screen: null

    // --- CONFIGURATION ---
    property bool   enclosed:       true
    property string indicatorStyle: "pills" // "pills" | "circles" | "numbers"

    baseColor:   root.enclosed ? Theme.surface0     :  "transparent"
    borderColor: root.enclosed ? ThemeState.border  :  "transparent"
    hoverColor:  root.enclosed ? ThemeState.hover   :  "transparent"

    // --- DATA ---
    readonly property var filteredWorkspaces: HyprlandService.getWorkspacesForScreen(root.screen)
    readonly property var _mon: Hyprland.monitorFor(root.screen)
    
    readonly property int activeWsId: {
        let trigger = Hyprland.focusedWorkspace;
        return _mon && _mon.activeWorkspace ? _mon.activeWorkspace.id : -1;
    }

    // --- HELPERS ---
    function indicatorWidth(isFocused, isHovered) {
        if (root.indicatorStyle === "circles") return 10
        if (isFocused) return 32
        if (isHovered) return 20
        return 12
    }

    function indicatorHeight() {
        return root.indicatorStyle === "circles" ? 10 : 6
    }

    function indicatorColor(isFocused, isHovered) {
        return (isFocused || isHovered) ? ThemeState.accent : ThemeState.hover
    }

    function numberColor(isFocused, isHovered) {
        if (isFocused) return ThemeState.accent
        return ThemeState.text
    }

    Item {
        id: shapesContainer
        visible: root.indicatorStyle !== "numbers"
        width: visible ? (shapeRow.width + (root.enclosed ? 24 : 0)) : 0
        height: parent.height

        property real gliderX: 0
        property real gliderWidth: 0

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
            
            add: Transition {
                NumberAnimation { property: "width"; from: 0; duration: 250; easing.type: Easing.OutQuart }
            }

            Repeater {
                model: root.indicatorStyle !== "numbers" ? root.filteredWorkspaces : 0

                Item {
                    id: shapeWsItem
                    visible: modelData.id >= 0

                    readonly property bool isFocused: modelData.id === root.activeWsId
                    readonly property bool isHovered: mouseArea.containsMouse

                    width: root.indicatorWidth(isFocused, isHovered)
                    height: root.indicatorHeight()
                    anchors.verticalCenter: parent.verticalCenter

                    // Smoothly animate the layout width as it stretches from dot to pill
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

                    Rectangle {
                        id: shapeIndicator
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: height / 2
                        
                        // Always visible, so it morphs seamlessly!
                        color: root.indicatorColor(shapeWsItem.isFocused, shapeWsItem.isHovered)

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MultiEffect {
                        source: shapeIndicator
                        anchors.fill: shapeIndicator
                        visible: shapeWsItem.isFocused
                        shadowEnabled: true
                        shadowColor: ThemeState.accent
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
        model: root.indicatorStyle === "numbers" ? root.filteredWorkspaces : 0

        ModuleItem {
            id: numberItem
            visible: modelData.id >= 0
            cursorShape: numberItem.isFocused ? Qt.ArrowCursor : Qt.PointingHandCursor

            readonly property bool isFocused: modelData.id === root.activeWsId

            onClicked: (button) => HyprlandService.goToWorkspace(modelData.id)
            onWheeled: (isUp) => {
                if (isUp) HyprlandService.prevWorkspace()
                else HyprlandService.nextWorkspace()
            }

            Text {
                text: ((modelData.id - 1) % 4) + 1
                color: root.numberColor(numberItem.isFocused, numberItem.hovered)
                font.family: root.textFont
                font.pixelSize: root.textSize
                font.bold: numberItem.isFocused

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
