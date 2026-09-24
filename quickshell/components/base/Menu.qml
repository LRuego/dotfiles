// components/base/Menu.qml
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
    // false: rows go edge-to-edge so hover fills the whole line.
    property bool padded:     true
    default property alias content: menuColumn.data

    // Padding inverted from the default: reserves no space (spacing:0) — every child owns its own inset.
    readonly property int _hpad: root.padded ? 12 : 0

    signal dismissed()
    onDismissed: root.open = false

    // --- WINDOW CONFIG ---
    anchor {
        item:        root.anchorItem
        edges:       Edges.Bottom | Edges.Left
        gravity:     Edges.Bottom | Edges.Right
        adjustment:  PopupAdjustment.All
        margins.top: 5
    }

    implicitWidth:  root.menuWidth
    implicitHeight: menuColumn.implicitHeight + menuRect.border.width * 2 + 5
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
        height:        menuColumn.implicitHeight + border.width * 2 // menuColumn insets by border.width

        color:        Theme.base
        radius:       Theme.cornerRadius
        border.color: Theme.overlay
        border.width: 1
        clip:         true // doesn't follow radius — round the true last row instead

        Column {
            id:                  menuColumn
            anchors.fill:        parent
            // border.width inset on every side — content must never paint over the border stroke.
            anchors.topMargin:    menuRect.border.width
            anchors.bottomMargin: menuRect.border.width
            anchors.leftMargin:   root._hpad + menuRect.border.width
            anchors.rightMargin:  root._hpad + menuRect.border.width
            spacing:              0
        }
    }
}
