// components/base/ContextMenuEntry.qml
import QtQuick
import Quickshell
import qs.services.ui
import qs.core

Item {
    id: root

    required property var entry
    property int          menuWidth: 200

    signal closeAll()

    width:          parent?.width ?? 200
    implicitHeight: entry.isSeparator ? 9 : 32

    property var subMenuInstance: null

    function openSubMenu() {
        if (subMenuInstance) return
        let comp = Qt.createComponent("ContextMenu.qml")
        if (comp.status !== Component.Ready) {
            console.log("[ContextMenuEntry] Failed to load ContextMenu:", comp.errorString())
            return
        }
        subMenuInstance = comp.createObject(root, {
            "open":       true,
            "anchorItem": root,
            "menuHandle": root.entry,
            "menuWidth":  root.menuWidth
        })
        subMenuInstance.closedAll.connect(() => root.closeAll())
        subMenuInstance.dismissed.connect(() => {
            if (subMenuInstance) {
                subMenuInstance.destroy()
                subMenuInstance = null
            }
        })
    }

    function closeSubMenu() {
        if (subMenuInstance) {
            subMenuInstance.destroy()
            subMenuInstance = null
        }
    }

    Component.onDestruction: closeSubMenu()

    // --- SEPARATOR ---
    Rectangle {
        visible:          entry.isSeparator
        anchors.centerIn: parent
        width:            parent.width
        height:           1
        color:            Theme.overlay
    }

    // --- MENU ITEM ---
    MenuItem {
        id:             entryItem
        visible:        !entry.isSeparator
        width:          parent.width
        implicitHeight: 32

        onClicked: (button) => {
            if (!entry.enabled) return
            if (button === Qt.LeftButton) {
                if (entry.hasChildren) {
                    openSubMenu()
                } else {
                    entry.triggered()
                    root.closeAll()
                }
            }
        }

        onHoveredChanged: {
            if (hovered && entry.hasChildren) {
                openSubMenu()
            } else if (!hovered) {
                closeSubMenu()
            }
        }

        // Check indicator
        Item {
            width:                  14
            height:                 parent.height
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                visible:          entry.checkState === Qt.Checked
                text:             "✓"
                color:            ThemeState.accent
                font.pixelSize:   Theme.fontSizeSmall
                font.bold:        true
            }
        }

        // Icon
        Image {
            visible:                entry.icon !== ""
            source:                 entry.icon
            width:                  16
            height:                 16
            sourceSize.width:       width
            sourceSize.height:      height
            anchors.verticalCenter: parent.verticalCenter
            opacity:                entry.enabled ? 1 : 0.4
        }

        // Text
        Text {
            text:                   entry.text
            color:                  entry.enabled ? ThemeState.text : Theme.subtext
            font.family:            Theme.fontFamily
            font.pixelSize:         Theme.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
            width:                  root.menuWidth - 60 - (entry.hasChildren ? 16 : 0)
            elide:                  Text.ElideRight
        }

        // Submenu arrow
        Text {
            visible:                entry.hasChildren
            text:                   "›"
            color:                  entry.enabled ? ThemeState.text : Theme.subtext
            font.pixelSize:         Theme.fontSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
