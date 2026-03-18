// components/bar/Volume.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamilyAlt

    // --- HELPERS ---
    readonly property string speakerIcon: {
        if (AudioService.isMuted)        return Assets.volumeMute
        if (AudioService.volume >= 60)   return Assets.volumeUp
        if (AudioService.volume >= 30)   return Assets.volumeDown
        return Assets.volume
    }

    readonly property color speakerColor: AudioService.isMuted ? Theme.urgent : Theme.text

    readonly property string micIcon: AudioService.isMicMuted ? Assets.microphoneMute : Assets.microphone

    readonly property color micColor: {
        if (AudioService.isMicMuted)   return Theme.urgent
        if (AudioService.isMicActive)  return Theme.warning
        return Theme.text
    }

    ModuleItem {
        id: volItem
        onClicked: AudioService.toggleMute()
        onWheeled: (isUp) => AudioService.adjustVolume(isUp)

        IconLabel {
            labelBold:  true
            icon:       root.speakerIcon
            iconColor:  root.speakerColor
            colorize:   true
            iconSize:   root.textSize
            iconWidth:  root.textSize
            text:       AudioService.volume + "%"
            textColor:  root.speakerColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  AudioService.volume < 100 ? 24 : 32
        }
    }

    ModuleItem {
        isHidden: !(volItem.hovered || hovered || AudioService.isMicActive || BarState.peekMode)
        onClicked: AudioService.toggleMic()
        onWheeled: (isUp) => AudioService.adjustMicVolume(isUp)

        IconLabel {
            labelBold:  true
            icon:       root.micIcon
            iconColor:  root.micColor
            colorize:   true
            iconSize:   root.textSize
            iconWidth:  root.textSize
            text:       AudioService.micVolume + "%"
            textColor:  root.micColor
            textFont:   root.textFont
            textSize:   root.textSize
            textWidth:  AudioService.micVolume < 100 ? 24 : 32
        }
    }
}
