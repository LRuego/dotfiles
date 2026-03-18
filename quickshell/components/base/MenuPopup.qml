// components/base/MenuPopup.qml
import QtQuick
import Quickshell
import "../../services/ui"
import "../../core"

PopupWindow {
    id: root

    // --- API ---
    property bool open: false
    property var anchorItem: null
    property int menuWidth: 250
    default property alias content: menuColumn.data
    
    signal dismissed()

    // --- WINDOW CONFIG ---
    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.All
        margins.top: 5
    }

    implicitWidth: root.menuWidth
    implicitHeight: menuColumn.implicitHeight + 35
    
    visible: open && anchorItem !== null
    color: "transparent"

    // --- WAYLAND RACE CONDITION FIX ---
    // Delay the focus registration slightly to ensure the window 
    // has actually finished mapping on the compositor before grabbing.
    Timer {
        id: focusDelay
        interval: 50
        onTriggered: FocusService.registerMenu(root)
    }

    onVisibleChanged: {
        if (visible) {
            focusDelay.start();
        } else {
            focusDelay.stop();
            FocusService.unregisterMenu(root);
        }
    }

    // --- VISUAL CONTAINER ---
    Rectangle {
        id: menuRect
        anchors.fill: parent
        anchors.topMargin: 5

        color: Theme.base
        radius: Theme.cornerRadius
        border.color: Theme.overlay
        border.width: 1

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12
        }
    }
}
