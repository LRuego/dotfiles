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

        Module {
            ModuleItem {
                IconLabel { labelBold: true; labelSize: root.textSize; icon: "󰖩" }
            }
            ModuleItem {
                IconLabel { labelBold: true; labelSize: root.textSize; icon: "󰂯"}
            }
        }

        //  --- VOLUME  ---
        Module {
            ModuleItem {
                id: volItem
                onClicked: audio.toggleMute()

                IconLabel {
                    labelBold: true
                    icon: audio.icon
                    iconSize: Theme.fontSizeTiny
                    iconWidth: root.textSize

                    text: audio.volume + "%"
                    textFont: root.textFont
                    textSize: root.textSize
                    textWidth: 32
                }
            }
            ModuleItem {
                // Collapsible Mic: Show if Vol hovered OR Mic hovered OR Mic is UNMUTED
                isHidden: !(volItem.hovered || hovered || audio.isMicActive)
                onClicked: audio.toggleMic()

                IconLabel {
                    labelBold: true
                    icon: audio.micIcon
                    iconSize: Theme.fontSizeTiny
                    iconWidth: root.textSize

                    text: audio.micVolume + "%"
                    textFont: root.textFont
                    textSize: root.textSize
                    textWidth: 32
                }
            }

        }

        //  --- DATE & TIME ---
        Module {
            ModuleItem {
                onClicked: console.log("Time Clicked!")

                IconLabel {
                    labelBold:    true

                    icon:         "󰅐"
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

                    icon:         ""
                    iconSize:     Theme.fontSizeTiny

                    text:         clockData.date
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }
        }
    }
}
