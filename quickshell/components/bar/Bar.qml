// windows/Bar.qml
import QtQuick
import Quickshell
import "../../core"
import "../base"
import "../../services"
import "."

PanelWindow {
    id: root
    
    // --- PROPERTIES ---
    property int    textSize:     Theme.fontSizeSmall
    property string textFont:     Theme.fontFamilyAlt

    // --- WINDOW CONFIG ---
    anchors {
        top:                      true
        left:                     true
        right:                    true
    }

    implicitHeight:               24
    color:                        Theme.barBackground

    // --- CENTER ---
    Workspaces {
        anchors.centerIn:         parent
    }

    // --- LEFT ---
    Row {
        anchors.left:             parent.left
        anchors.leftMargin:       15
        anchors.top:              parent.top
        anchors.bottom:           parent.bottom
        spacing:                  10
   }

    // --- RIGHT ---
    Row {
        anchors.right:            parent.right
        anchors.rightMargin:      15
        anchors.top:              parent.top
        anchors.bottom:           parent.bottom
        spacing:                  10

        //  --- CONNECTIVITY ---
        Module {
            ModuleItem {
                id: tsModule
                onClicked: (button) => {
                    if (button === Qt.RightButton) {
                        TailscaleService.openMenu(tsModule)
                    } else {
                        TailscaleService.toggle()
                    }
                }

                IconLabel { 
                    id: tsIcon
                    icon: TailscaleService.icon 
                    colorize: false 
                    
                    SequentialAnimation on opacity {
                        running: TailscaleService.transitioning
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                    onVisibleChanged: if (!TailscaleService.transitioning) opacity = 1.0
                }
            }

            ModuleItem {
                IconLabel {
                    labelBold: true
                    icon: NetworkService.icon
                    iconColor: NetworkService.statusColor
                    colorize: true 
                    iconWidth: Theme.fontSize
                }
            }

            ModuleItem {
                id: btItem
                onClicked: {
                    if (BluetoothService.adapter) {
                        BluetoothService.adapter.enabled = !BluetoothService.adapter.enabled
                    }
                }

                IconLabel {
                    labelBold: true
                    icon: BluetoothService.icon
                    iconColor: BluetoothService.statusColor
                    colorize: true 
                }
            }
        }

        //  --- VOLUME  ---
        Module {
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

        //  --- DATE & TIME ---
        Module {
            ModuleItem {
                onClicked: console.log("Time Clicked!")
                IconLabel {
                    labelBold:    true
                    icon:         Assets.clock
                    iconSize:     root.textSize
                    colorize:     true
                    text:         ClockService.time
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }
            ModuleItem {
                id: calendarItem
                onClicked: (button) => {
                    sampleMenu.anchorItem = calendarItem
                    sampleMenu.open = !sampleMenu.open
                }
                IconLabel {
                    labelBold:    true
                    icon:         Assets.calendar
                    iconSize:     Theme.fontSizeTiny
                    colorize:     true
                    text:         ClockService.date
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }
        }
    }
}
