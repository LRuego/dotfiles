// components/base/ToolTip.qml
import QtQuick
import Quickshell
import qs.core

PopupWindow {
    id: root

    // --- API ---
    property var    anchorItem: null
    property string text:       ""
    property int    delay:      500

    // --- WINDOW CONFIG ---
    // Empty mask so tooltip never steals focus or intercepts clicks
    mask: Region { item: null }

    anchor {
        item:       root.anchorItem ?? null
        edges:      Edges.Top
        gravity:    Edges.Top
        adjustment: PopupAdjustment.All

        rect: {
            if (!anchorItem) return Qt.rect(0, 0, 0, 0)
            return Qt.rect(
                (anchorItem.width / 2) - (root.implicitWidth / 2),
                0,
                root.implicitWidth,
                anchorItem.height
            )
        }

        margins.bottom: 6
    }

    implicitWidth:  Math.max(40, textItem.contentWidth + 16)
    implicitHeight: Math.max(20, textItem.contentHeight + 10)

    visible: false
    color:   "transparent"

    // --- API ---
    function show(item, content) {
        if (root.visible && root.anchorItem === item && root.text === content) return
        root.anchorItem = item
        root.text       = content
        delayTimer.restart()
    }

    function hide(item) {
        if (item === null || item === undefined || root.anchorItem === item) {
            delayTimer.stop()
            root.visible = false
        }
    }

    Timer {
        id:          delayTimer
        interval:    root.delay
        onTriggered: root.visible = true
    }

    // --- VISUALS ---
    Rectangle {
        anchors.fill:  parent
        color:         Theme.base
        radius:        Theme.cornerRadius
        border.color:  Theme.overlay
        border.width:  1

        Text {
            id:                  textItem
            anchors.centerIn:    parent
            text:                root.text
            color:               Theme.text
            font.family:         Theme.fontFamily
            font.pixelSize:      Theme.fontSizeTiny
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
        }
    }
}
