// widgets/Workspaces.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "../theme.js" as Theme

Item {
    id: root // Container
    implicitWidth: internalRow.implicitWidth
    implicitHeight: internalRow.implicitHeight

    // --- SCROLL SWITCHING ---
    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                Hyprland.dispatch("workspace m-1") // Previous
            } else {
                Hyprland.dispatch("workspace m+1") // Next
            }
        }
    }

    Row {
        id: internalRow
        spacing: 8
        anchors.centerIn: parent

        Repeater {
            model: Hyprland.workspaces

            Item {
                id: wsItem
                // Hide Magic Workspaces
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

                    // Color Logic
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
                        onClicked: Hyprland.dispatch("workspace " + modelData.id)

                        // Handle scroll on the pill itself
                        onWheel: (wheel) => {
                            if (wheel.angleDelta.y > 0) {
                                Hyprland.dispatch("workspace m-1")
                            } else {
                                Hyprland.dispatch("workspace m+1")
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
