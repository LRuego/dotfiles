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

            // 1. Find all ModuleItems
            for (let i = 0; i < children.length; i++) {
                if (children[i] && typeof children[i].pos !== "undefined") {
                    items.push(children[i])

                    // --- DATA SYNC ---
                    // Push styles down to the child.
                    // This creates a dynamic binding so if Module colors change,
                    // the child updates automatically.
                    children[i].fullRadius = Qt.binding(function() { return root.radius })
                    children[i].hoverColor = Qt.binding(function() { return root.hoverColor })
                }
            }

            // 2. Assign Positions
            if (items.length === 1) {
                items[0].pos = "single"
            } else if (items.length > 1) {
                items[0].pos = "left"
                for (let j = 1; j < items.length - 1; j++) {
                    items[j].pos = "mid"
                }
                items[items.length - 1].pos = "right"
            }
        }
    }
}
