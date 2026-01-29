// components/ModuleItem.qml
import QtQuick
import "../theme.js" as Theme

Item {
    id: root

    default property alias content: row.data
    signal clicked()
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

    // Calculate natural width
    readonly property real naturalWidth: Math.max(20, row.width + padLeft + padRight)

    // Animated Width Logic
    width: isHidden ? 0 : naturalWidth
    visible: width > 0
    clip: true // Prevent overflow during animation

    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

    height:                       parent.height

    // --- HOVER BACKGROUND ---
    Rectangle {
        id: bg
        anchors.fill:             parent
        color:                    root.hoverColor
        visible:                  mouse.containsMouse
        radius:                   root.fullRadius

        // Square Right Patch
        Rectangle {
            visible:              root.pos === "left" || root.pos === "mid"
            width:                bg.radius
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            color:                root.hoverColor
        }

        // Square Left Patch
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

    // --- CLICK ---
    MouseArea {
        id: mouse
        anchors.fill:             parent
        z:                        99
        hoverEnabled:             true
        cursorShape:              Qt.PointingHandCursor
        onClicked:                root.clicked()
    }
}
