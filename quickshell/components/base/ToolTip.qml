// components/base/ToolTip.qml
import QtQuick
import Quickshell
import qs.core

PopupWindow {
    id: root

    // --- API ---
    property var anchorItem: null
    property string text: ""
    property real mouseX: 0
    property real mouseY: 0
    
    // Config
    property bool followCursor: true
    property int direction: Edges.Top
    property int delay: 500

    // --- WINDOW CONFIG ---
    // CRITICAL FIX: Make the entire tooltip pass through mouse clicks
    // by masking it with an empty region. This prevents the tooltip from
    // stealing focus from the hovered window and breaking the hover state.
    mask: Region { item: null }

    anchor {
        item: root.anchorItem ? root.anchorItem : null
        edges: root.direction
        gravity: root.direction
        
        rect: {
            if (!anchorItem) return Qt.rect(0, 0, 0, 0);
            
            if (!followCursor) {
                return Qt.rect(0, 0, anchorItem.width, anchorItem.height);
            }
            
            return Qt.rect(root.mouseX, root.mouseY, 1, 1);
        }

        adjustment: PopupAdjustment.All
        
        margins {
            bottom: root.direction === Edges.Top ? 24 : 0
            top:    root.direction === Edges.Bottom ? 24 : 0
            right:  root.direction === Edges.Left ? 24 : 0
            left:   root.direction === Edges.Right ? 24 : 0
        }
    }

    implicitWidth: Math.max(40, textItem.contentWidth + 16)
    implicitHeight: Math.max(20, textItem.contentHeight + 10)
    
    visible: false 
    color: "transparent"

    // --- LOGIC ---
    function show(item, content, x, y, options) {
        // 1. Apply per-invocation options or revert to defaults
        if (options) {
            root.followCursor = options.followCursor !== undefined ? options.followCursor : true;
            root.direction = options.direction !== undefined ? options.direction : Edges.Top;
            root.delay = options.delay !== undefined ? options.delay : 500;
        } else {
            root.followCursor = true;
            root.direction = Edges.Top;
            root.delay = 500;
        }

        // 2. Update coords if already showing the same tooltip
        if (root.anchorItem === item && root.text === content) {
            root.mouseX = x;
            root.mouseY = y;
            return;
        }

        // 3. Set new anchor and text, restart delay
        root.anchorItem = item;
        root.text = content;
        root.mouseX = x;
        root.mouseY = y;
        delayTimer.restart();
    }

    function hide(item) {
        if (item === undefined || root.anchorItem === item) {
            delayTimer.stop();
            root.visible = false;
        }
    }

    Timer {
        id: delayTimer
        interval: root.delay
        onTriggered: root.visible = true
    }

    // --- VISUALS ---
    Rectangle {
        anchors.fill: parent
        color: Theme.base
        radius: Theme.cornerRadius
        border.color: Theme.overlay
        border.width: 1

        Text {
            id: textItem
            anchors.centerIn: parent
            text: root.text
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
