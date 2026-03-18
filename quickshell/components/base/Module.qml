// components/base/Module.qml
import QtQuick
import "../../core"
import "../../services/ui"

Rectangle {
    id: root

    // --- API ---
    default property alias content: internalRow.data

    // --- SHAPE ---
    property bool   square:       false
    property int    radiusConfig: Theme.cornerRadius

    // --- COLORS & BORDER ---
    property color  baseColor:    Theme.surface0
    property color  hoverColor:   ThemeState.hover
    property color  borderColor:  ThemeState.border
    property int    borderWidth:  1

    // --- LAYOUT ---
    implicitHeight:               32
    height:                       parent ? parent.height : implicitHeight
    width:                        internalRow.width + (root.borderWidth * 2)

    // --- STYLE ---
    color:                        root.baseColor
    border.width:                 0
    radius:                       root.square ? 0 : Math.min(height / 2, root.radiusConfig)

    // --- CONTENT CONTAINER ---
    Item {
        anchors.fill:             parent
        anchors.margins:          root.borderWidth
        clip:                     true

        Row {
            id: internalRow
            height:               parent.height
            spacing:              0

            onChildrenChanged:        updateProps()
            Component.onCompleted:    updateProps()

            function updateProps() {
                let items = []

                for (let i = 0; i < children.length; i++) {
                    let child = children[i]
                    if (!child) continue

                    try { child.visibleChanged.disconnect(updateProps) } catch(e) {}
                    child.visibleChanged.connect(updateProps)

                    if (child.visible && typeof child.pos !== "undefined") {
                        items.push(child)
                        child.fullRadius = Qt.binding(function() { return root.radius })
                        child.hoverColor = Qt.binding(function() { return root.hoverColor })
                    }
                }

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

    // --- BORDER OVERLAY ---
    Rectangle {
        anchors.fill:             parent
        color:                    "transparent"
        border.color:             root.borderColor
        border.width:             root.borderWidth
        radius:                   root.radius
        z:                        99
    }
}
