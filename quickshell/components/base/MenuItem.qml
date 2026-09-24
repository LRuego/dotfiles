// components/base/MenuItem.qml
import QtQuick
import qs.core
import qs.services.ui

Rectangle {
    id: root
    
    // --- API ---
    width: parent ? parent.width : 200
    implicitHeight: 36 

    default property alias content: innerRow.data
    signal clicked(int button)
    
    property bool hovered: mouseArea.containsMouse
    property color hoverColor: ThemeState.hover

    // --- TOOLTIP API ---
    property string tooltip: ""

    // --- STATE ---
    // Precedence: disabled > active > inactive > default.
    property bool active:   false
    property bool inactive: false
    property bool disabled: false

    // --- VISUALS ---
    color:   root.disabled ? "transparent" : ((root.active || hovered) ? hoverColor : "transparent")
    opacity: root.disabled ? 0.4 : (root.inactive ? 0.6 : 1.0)
    radius: Theme.cornerRadius

    // --- INTERACTION ---
    // Declared before the content so a nested interactive child can still get its own clicks.
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled:      !root.disabled
        hoverEnabled: !root.disabled
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: (mouse) => root.clicked(mouse.button)
    }

    Item {
        id: innerContainer
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        Row {
            id: innerRow
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
        }
    }

    readonly property real mouseX: mouseArea.mouseX
    readonly property real mouseY: mouseArea.mouseY
}
