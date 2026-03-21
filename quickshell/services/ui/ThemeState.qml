// services/ui/ThemeState.qml
pragma Singleton
import QtQuick
import Quickshell
import qs.core
import qs.services.system

Item {
    id: root

    readonly property color accent:   GamemodeService.isActive ? Theme.secondary      : Theme.primary
    readonly property color border:   GamemodeService.isActive ? Theme.overlayPurple  : Theme.overlay
    readonly property color hover:    GamemodeService.isActive ? Theme.surface1Purple : Theme.surface1
    readonly property color pressed:  GamemodeService.isActive ? Theme.surface2Purple : Theme.surface2
    readonly property color text:     GamemodeService.isActive ? Theme.textPurple     : Theme.text
}
