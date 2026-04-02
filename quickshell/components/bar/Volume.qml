// components/bar/Volume.qml
import QtQuick
import Quickshell
import qs.core
import qs.components.base
import qs.services.system
import qs.services.ui

Module {
    id: root

    // --- SCALE (set by Bar) ---
    property int    iconSize: Theme.fontSizeLarge
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    // --- HELPERS ---
    readonly property string speakerIcon: {
        if (AudioService.isMuted)        return Assets.volumeMute
        if (AudioService.volume >= 60)   return Assets.volumeUp
        if (AudioService.volume >= 30)   return Assets.volumeDown
        return Assets.volume
    }

    readonly property color speakerColor: AudioService.isMuted ? Theme.urgent : ThemeState.text

    readonly property string micIcon: AudioService.isMicMuted ? Assets.microphoneMute : Assets.microphone

    readonly property color micColor: {
        if (AudioService.isMicMuted)  return Theme.urgent
        if (PrivacyService.micActive) return Theme.warning
        return ThemeState.text
    }

    ModuleItem {
        id: volItem
        onClicked:  AudioService.toggleMute()
        onWheeled: (isUp) => AudioService.adjustVolume(isUp)

        IconLabel {
            labelBold:  true
            icon:       root.speakerIcon
            iconColor:  root.speakerColor
            iconSize:   root.iconSize
            colorize:   true

            text:       AudioService.volume + "%"
            textColor:  root.speakerColor
            textFont:   root.textFont
            textWidth:  AudioService.volume < 100 ? 24 : 32
            textSize:   root.textSize
        }
    }

    ModuleItem {
        isHidden: !(volItem.hovered || hovered || PrivacyService.micActive || BarState.peekMode)
        onClicked:  AudioService.toggleMic()
        onWheeled: (isUp) => AudioService.adjustMicVolume(isUp)

        IconLabel {
            labelBold:  true
            icon:       root.micIcon
            iconColor:  root.micColor
            iconSize:   root.iconSize
            colorize:   true

            text:       AudioService.micVolume + "%"
            textColor:  root.micColor
            textFont:   root.textFont
            textWidth:  AudioService.micVolume < 100 ? 24 : 32
            textSize:   root.textSize
        }
    }
}
