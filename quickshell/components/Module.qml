// components/Module.qml
import QtQuick
import "../theme.js" as Theme

Rectangle {
    id: root

    // --- API ---
    default property alias content: internalRow.data

    // --- SHAPE ---
    property bool   square:       false
    property int    radiusConfig: Theme.cornerRadius

    // --- COLORS & BORDER ---
    property color  baseColor:    Theme.surface0
    property color  hoverColor:   Theme.surface1
    property color  borderColor:  Theme.overlay
    property int    borderWidth:  1

    // --- LAYOUT ---
    implicitHeight:               32
    anchors.top:                  parent ? parent.top : undefined
    anchors.bottom:               parent ? parent.bottom : undefined
    width:                        internalRow.width

    // --- STYLE ---
    color:                        root.baseColor
    border.color:                 root.borderColor
    border.width:                 root.borderWidth
    radius:                       root.square ? 0 : Math.min(height / 2, root.radiusConfig)

    // --- LOGIC ---
    Row {
        id: internalRow
        anchors.centerIn:         parent
        height:                   parent.height
        spacing:                  0

        onChildrenChanged:        updateProps()
        Component.onCompleted:    updateProps()

        function updateProps() {
            let items = []

            // --- 1. FILTER VISIBLE ITEMS ---
            for (let i = 0; i < children.length; i++) {
                let child = children[i]

                // Validate child
                if (!child) continue

                // --- DYNAMIC UPDATES ---
                // Re-connect to visibleChanged signal safely
                try { child.visibleChanged.disconnect(updateProps) } catch(e) {}
                child.visibleChanged.connect(updateProps)

                // Check visibility & validity
                if (child.visible && typeof child.pos !== "undefined") {
                    items.push(child)

                    // --- BIND PROPERTIES ---
                    child.fullRadius = Qt.binding(function() { return root.radius })
                    child.hoverColor = Qt.binding(function() { return root.hoverColor })
                }
            }

            // --- 2. ASSIGN POSITIONS ---
            if (items.length === 1) {
                items[0].pos = "single"
            } else if (items.length > 1) {
                // First
                items[0].pos = "left"

                // Middle(s)
                for (let j = 1; j < items.length - 1; j++) {
                    items[j].pos = "mid"
                }

                // Last
                items[items.length - 1].pos = "right"
            }
        }
    }
}
