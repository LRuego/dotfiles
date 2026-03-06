import QtQuick
import "../base"
import "../../core"

MenuPopup {
    id: root
    
    // Manual state management for self-contained menus
    onDismissed: open = false

    menuWidth: 200

    // --- TITLE ---
    Text { 
        text: "Sample Menu"
        color: Theme.primary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true 
    }
    
    // --- DIVIDER ---
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.overlay
    }

    // --- BODY TEXT ---
    Text {
        text: "This is a blank template for your custom menus."
        width: parent.width
        wrapMode: Text.WordWrap
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    // --- INTERACTIVE BUTTON ---
    Rectangle {
        width: parent.width
        height: 32
        color: tap.pressed ? Theme.surface2 : (tap.containsHover ? Theme.surface1 : "transparent")
        radius: 4
        border.color: Theme.overlay
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "Click Me"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        TapHandler {
            id: tap
            onTapped: console.log("Sample menu button clicked!")
        }
    }
}
