// services/ThemeState.qml
pragma Singleton
import QtQuick
import Quickshell
import "../core"

Item {
    id: root

    readonly property color accent: GamemodeService.isActive ? Theme.secondary : Theme.primary
    readonly property color border: GamemodeService.isActive ? Theme.secondary : Theme.overlay
}
