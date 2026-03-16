// components/bar/Volume.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"

Module {
    id: root

    property int    textSize:     Theme.fontSizeSmall
    property string textFont:     Theme.fontFamilyAlt

    ModuleItem {
        id: volItem
        onClicked: AudioService.toggleMute()
        onWheeled: (isUp) => AudioService.adjustVolume(isUp)

        IconLabel {
            labelBold: true
            icon: AudioService.icon
            iconColor: AudioService.speakerColor
            colorize: true
            iconSize: root.textSize
            iconWidth: root.textSize

            text: AudioService.volume + "%"
            textColor: AudioService.speakerColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: AudioService.volume < 100 ? 24 : 32
        }
    }
    ModuleItem {
        isHidden: !(volItem.hovered || hovered || AudioService.isMicActive)
        onClicked: AudioService.toggleMic()
        onWheeled: (isUp) => AudioService.adjustMicVolume(isUp)

        IconLabel {
            labelBold: true
            icon: AudioService.micIcon
            iconColor: AudioService.micColor
            colorize: true
            iconSize: root.textSize
            iconWidth: root.textSize

            text: AudioService.micVolume + "%"
            textColor: AudioService.micColor
            textFont: root.textFont
            textSize: root.textSize
            textWidth: AudioService.micVolume < 100 ? 24 : 32
        }
    }
}
