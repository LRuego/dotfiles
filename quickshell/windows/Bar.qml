// windows/Bar.qml
import QtQuick
import Quickshell
import "../theme.js" as Theme
import "../components"
import "../services"
import "../widgets"

PanelWindow {
    id: root
    // --- LOGIC ---
    ClockService { id: clockData }
    AudioService { id: audio }
    BluetoothService { id: bt }
    NetworkService { id: net }

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
                IconLabel { icon: Assets.tailscaleOn }
            }

            ModuleItem {
                IconLabel {
                    labelBold: true
                    icon: net.icon
                    iconColor: net.statusColor
                    iconWidth: Theme.fontSize
                }
            }

            ModuleItem {
                id: btItem
                // Click to toggle Bluetooth Power
                onClicked: {
                    if (bt.adapter) bt.adapter.enabled = !bt.adapter.enabled
                }

                IconLabel {
                    labelBold: true
                    icon: bt.icon
                    iconColor: bt.statusColor
                }
            }
        }

        //  --- VOLUME  ---
        Module {
            ModuleItem {
                id: volItem
                onClicked: audio.toggleMute()
                onWheeled: (wheel) => audio.adjustVolume(wheel.angleDelta.y > 0)

                IconLabel {
                    labelBold: true

                    icon: audio.icon
                    iconColor: audio.speakerColor
                    iconSize: root.textSize
                    iconWidth: root.textSize

                    text: audio.volume + "%"
                    textColor: audio.speakerColor
                    textFont: root.textFont
                    textSize: root.textSize
                    textWidth: audio.volume < 100 ? 24 : 32
                }
            }
            ModuleItem {
                // Collapsible Mic: Show if Vol hovered OR Mic hovered OR Mic is UNMUTED
                isHidden: !(volItem.hovered || hovered || audio.isMicActive)
                onClicked: audio.toggleMic()
                onWheeled: (wheel) => audio.adjustMicVolume(wheel.angleDelta.y > 0)

                IconLabel {
                    labelBold: true

                    icon: audio.micIcon
                    iconColor: audio.micColor
                    iconSize: root.textSize
                    iconWidth: root.textSize

                    text: audio.micVolume + "%"
                    textColor: audio.micColor
                    textFont: root.textFont
                    textSize: root.textSize
                    textWidth: audio.micVolume < 100 ? 24 : 32

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

                    text:         clockData.time
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }
            ModuleItem {
                onClicked: console.log("Date Clicked!")

                IconLabel {
                    labelBold:    true

                    icon:         Assets.calendar
                    iconSize:     Theme.fontSizeTiny

                    text:         clockData.date
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }
        }
    }
}
