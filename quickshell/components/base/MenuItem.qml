// components/base/MenuItem.qml
import QtQuick
import "../../core"

Rectangle {
    id: root
    
    // --- API ---
    width: parent ? parent.width : 200
    implicitHeight: 36 

    default property alias content: innerRow.data
    signal clicked(int button)
    
    property bool hovered: mouseArea.containsMouse
    property color hoverColor: Theme.surface1
    
    // --- TOOLTIP API ---
    property string tooltip: ""

    // --- VISUALS ---
    color: hovered ? hoverColor : "transparent"
    radius: Theme.cornerRadius

    Item {
        id: innerContainer
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        
        Row {
            id: innerRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
        }
    }

    // --- INTERACTION ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => root.clicked(mouse.button)
    }
    
    readonly property real mouseX: mouseArea.mouseX
    readonly property real mouseY: mouseArea.mouseY
}
