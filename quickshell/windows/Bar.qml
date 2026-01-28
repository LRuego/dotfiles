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
                IconLabel {
                    labelBold:    true

                    icon:         ""
                    iconSize:     root.textSize

                    text:         "100%"
                    textFont:     root.textFont
                    textSize:     root.textSize
                }
            }

            ModuleItem {
                IconLabel {
                    labelBold:    true

                    icon:         ""
                    iconSize:     Theme.fontSizeTiny

                    text:         "100%"
                    textFont:     root.textFont
                    textSize:     root.textSize
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
