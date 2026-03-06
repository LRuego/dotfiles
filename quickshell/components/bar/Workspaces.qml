// widgets/Workspaces.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import "../../core"
import "../../services"

Item {
    id: root
    implicitWidth: internalRow.implicitWidth
    implicitHeight: internalRow.implicitHeight

    // --- SCROLL SWITCHING ---
    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                HyprlandService.prevWorkspace()
            } else {
                HyprlandService.nextWorkspace()
            }
        }
    }

    Row {
        id: internalRow
        spacing: 8
        anchors.centerIn: parent

        Repeater {
            // Bind to our centralized service
            model: HyprlandService.workspaces

            Item {
                id: wsItem
                visible: modelData.id >= 0

                // --- STATE ---
                readonly property bool isFocused: modelData.active
                readonly property bool isHovered: mouseArea.containsMouse

                // --- ANIMATED PROPERTIES ---
                width: isFocused ? 48 : (isHovered ? 32 : 24)
                height: 8

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuart }
                }

                Rectangle {
                    id: barRect
                    anchors.fill: parent
                    radius: height / 2

                    color: {
                        if (isFocused) return Theme.primary
                        if (isHovered) return Theme.surface2
                        return Theme.surface1
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: HyprlandService.goToWorkspace(modelData.id)

                        onWheel: (wheel) => {
                            if (wheel.angleDelta.y > 0) {
                                HyprlandService.prevWorkspace()
                            } else {
                                HyprlandService.nextWorkspace()
                            }
                        }
                    }
                }

                // Glow Effect for Focused Workspace
                MultiEffect {
                    source: barRect
                    anchors.fill: barRect
                    visible: wsItem.isFocused
                    shadowEnabled: true
                    shadowColor: Theme.primary
                    shadowBlur: 0.8
                    shadowScale: 1.2
                    opacity: 0.7
                }
            }
        }
    }
}
