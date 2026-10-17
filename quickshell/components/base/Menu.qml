// components/base/Menu.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services.ui
import qs.core

// A top-layer surface, not a popup: Hyprland draws every layer popup above all layers,
// so a popup menu would cover overlay notifications. As a layer, notifications stay on top.
PanelWindow {
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
    WlrLayershell.layer:     WlrLayer.Top
    WlrLayershell.namespace: "quickshell-menu"
    exclusionMode:           ExclusionMode.Ignore // margins are measured from the screen edge, not below the bar

    screen: root.anchorItem?.QsWindow.window?.screen ?? null

    anchors {
        top:  true
        left: true
    }

    // Like the old popup placement: left-aligned under the anchor, flipped to right-aligned
    // if that would run off the screen, then clamped as a last resort.
    // Recomputed when the menu opens (the bar doesn't move while it's open).
    property point _origin: Qt.point(0, 0)
    onOpenChanged: if (open) _placeUnderAnchor()

    function _placeUnderAnchor() {
        if (!root.anchorItem) return
        let p = root.anchorItem.mapToItem(null, 0, root.anchorItem.height)
        let screenW = root.screen?.width ?? Infinity
        let x = p.x
        if (x + root.menuWidth > screenW) x = p.x + root.anchorItem.width - root.menuWidth
        x = Math.max(4, Math.min(x, screenW - root.menuWidth - 4))
        root._origin = Qt.point(x, p.y)
    }

    margins {
        left: root._origin.x
        top:  root._origin.y
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
