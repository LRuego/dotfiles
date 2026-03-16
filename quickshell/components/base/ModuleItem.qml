// components/ModuleItem.qml
import QtQuick
import "../../core"

Item {
    id: root

    default property alias content: row.data
    
    // Explicit signal signatures to prevent "Too many arguments" warnings
    signal clicked(int button)
    signal wheeled(bool isUp)
    
    property alias hovered: mouse.containsMouse

    // --- RECEIVED PROPERTIES ---
    property string pos:          "single"
    property real   fullRadius:   Theme.cornerRadius
    property color  hoverColor:   Theme.surface1

    // --- API ---
    property bool isHidden: false

    // --- LAYOUT ---
    property int    padLeft:      (pos === "right" || pos === "mid") ? 5 : 10
    property int    padRight:     (pos === "left"  || pos === "mid") ? 5 : 10

    readonly property int naturalWidth: Math.ceil(Math.max(20, row.width + padLeft + padRight))

    width: isHidden ? 0 : naturalWidth
    visible: width > 0
    clip: true 

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuart
        }
    }

    height: parent.height

    // --- HOVER BACKGROUND ---
    Rectangle {
        id: bg
        anchors.fill:             parent
        color:                    root.hoverColor
        visible:                  mouse.containsMouse
        radius:                   root.fullRadius

        Rectangle {
            visible:              root.pos === "left" || root.pos === "mid"
            width:                bg.radius
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            color:                root.hoverColor
        }

        Rectangle {
            visible:              root.pos === "right" || root.pos === "mid"
            width:                bg.radius
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            color:                root.hoverColor
        }
    }

    // --- CONTENT ---
    Row {
        id: row
        anchors.verticalCenter:   parent.verticalCenter
        x:                        root.padLeft
        spacing:                  8
    }

    // --- CLICK & SCROLL ---
    MouseArea {
        id: mouse
        anchors.fill:             parent
        z:                        99
        hoverEnabled:             true
        acceptedButtons:          Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape:              Qt.PointingHandCursor
        
        // Pass only the button to the signal
        onClicked: (mouse) => root.clicked(mouse.button)
        
        // Pass only the direction boolean to the signal
        onWheel: (wheel) => root.wheeled(wheel.angleDelta.y > 0)
    }
}
