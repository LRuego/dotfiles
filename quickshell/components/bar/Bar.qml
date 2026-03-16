// components/bar/Bar.qml
import QtQuick
import QtQuick.Layouts
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

    Item {
        anchors.fill: parent

        // --- LEFT ---
        Row {
            anchors {
                left: parent.left
                leftMargin: 15
                top: parent.top
                bottom: parent.bottom
            }
            spacing: 10

            DateTime {}

            Workspaces {
                enclosed: true
                indicatorStyle: "pills"
            }
        }

        // --- ABSOLUTE CENTER ---
        WindowTitle {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
        }

        // --- RIGHT ---
        Row {
            anchors {
                right: parent.right
                rightMargin: 15
                top: parent.top
                bottom: parent.bottom
            }
            spacing: 10

            SystemResources {}

            Volume {}

            Connectivity {}

        }
    }
}
