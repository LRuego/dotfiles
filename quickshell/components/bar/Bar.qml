// components/bar/Bar.qml
import Quickshell
import QtQuick
import qs.core
import qs.components.base

PanelWindow {
    id: root

    // --- SCALE PROPERTIES ---
    // These are the single source of truth for all bar module sizing.
    // Modules do not define their own textSize/textFont defaults —
    // they receive these explicitly from here.
    property int    iconSize: Theme.fontSizeIcon
    property int    textSize: Theme.fontSizeSmall
    property string textFont: Theme.fontFamily

    // --- WINDOW CONFIG ---
    anchors {
        top:   true
        left:  true
        right: true
    }

    implicitHeight: 24
    color:          Theme.barBackground

    Item {
        anchors.fill: parent

        // --- LEFT ---
        Row {
            anchors {
                left:       parent.left
                leftMargin: 15
                top:        parent.top
                bottom:     parent.bottom
            }
            spacing: 10

            DateTime    { iconSize: root.iconSize; textSize: root.textSize; textFont: root.textFont }

            Workspaces  { enclosed: true; indicatorStyle: "pills" }
        }

        // --- ABSOLUTE CENTER ---
        WindowTitle {
            anchors.horizontalCenter: parent.horizontalCenter
            height:   parent.height
            textSize: root.textSize
            textFont: root.textFont
        }

        // --- RIGHT ---
        Row {
            anchors {
                right:       parent.right
                rightMargin: 15
                top:         parent.top
                bottom:      parent.bottom
            }
            spacing: 10

            Tray            { iconSize: 14 } // Hardcode Tray Size depending on root.iconSize
            SystemResources { iconSize: root.iconSize; textSize: root.textSize; textFont: root.textFont }
            Volume          { iconSize: root.iconSize; textSize: root.textSize; textFont: root.textFont }
            Connectivity    { iconSize: root.iconSize; textSize: root.textSize; textFont: root.textFont }
            Notifications   { iconSize: root.iconSize }
        }
    }
}
