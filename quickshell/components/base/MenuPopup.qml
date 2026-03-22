// components/base/MenuPopup.qml
import QtQuick
import Quickshell
import qs.services.ui
import qs.core

PopupWindow {
    id: root

    // --- API ---
    property bool open:       false
    property var  anchorItem: null
    property int  menuWidth:  250
    default property alias content: menuColumn.data

    signal dismissed()

    // --- WINDOW CONFIG ---
    anchor {
        item:        root.anchorItem
        edges:       Edges.Bottom | Edges.Left
        gravity:     Edges.Bottom | Edges.Right
        adjustment:  PopupAdjustment.All
        margins.top: 5
    }

    implicitWidth:  root.menuWidth
    implicitHeight: menuColumn.implicitHeight + 29
    visible:        open && anchorItem !== null
    color:          "transparent"

    // --- FOCUS ---
    Timer {
        id:          focusDelay
        interval:    50
        onTriggered: FocusService.registerMenu(root)
    }

    onVisibleChanged: {
        if (visible) {
            focusDelay.start()
        } else {
            focusDelay.stop()
            FocusService.unregisterMenu(root)
        }
    }

    // --- VISUALS ---
    Rectangle {
        id:            menuRect
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.topMargin: 5
        height:        menuColumn.implicitHeight + 24

        color:        Theme.base
        radius:       Theme.cornerRadius
        border.color: Theme.overlay
        border.width: 1

        Column {
            id:              menuColumn
            anchors.fill:    parent
            anchors.margins: 12
            spacing:         8
        }
    }
}
