// components/base/ContextMenuEntry.qml
import QtQuick
import Quickshell
import qs.services.ui
import qs.core

Item {
    id: entryRoot

    required property var entry
    property int          menuWidth: 200

    signal closeAll()

    width:          parent?.width ?? 200
    implicitHeight: entry.isSeparator ? 9 : 22

    property var subMenuInstance: null

    function openSubMenu() {
        if (subMenuInstance) return
        let comp = Qt.createComponent("ContextMenu.qml")
        if (comp.status !== Component.Ready) {
            console.log("[ContextMenuEntry] Failed to load ContextMenu:", comp.errorString())
            return
        }
        subMenuInstance = comp.createObject(entryRoot, {
            "open":       true,
            "anchorItem": entryRoot,
            "menuHandle": entryRoot.entry,
            "menuWidth":  entryRoot.menuWidth
        })
        subMenuInstance.closedAll.connect(() => entryRoot.closeAll())
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
        width:            parent.width - 20
        height:           1
        color:            Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.12)
    }

    // --- MENU ITEM ---
    MenuItem {
        id:             entryItem
        visible:        !entry.isSeparator
        width:          parent.width
        implicitHeight: 22
        contentSpacing: 4
        radius:         5
        hoverColor:     ThemeState.accent

        // Hovered rows sit on the accent pill, so their text flips to the base colour.
        readonly property color textColor: !entry.enabled ? Theme.subtext : (hovered ? Theme.base : ThemeState.text)

        onClicked: (button) => {
            if (!entry.enabled) return
            if (button === Qt.LeftButton) {
                if (entry.hasChildren) {
                    openSubMenu()
                } else {
                    entry.triggered()
                    entryRoot.closeAll()
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
            width:                  14 // macOS-style gutter, always reserved
            height:                 parent.height
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                visible:          entry.checkState === Qt.Checked
                text:             "✓"
                color:            entryItem.textColor
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

        // Text — same entry color vocabulary as ContextMenu.qml's static entries.
        Text {
            text:                   entry.text
            color:                  entryItem.textColor
            font.family:            Theme.fontFamily
            font.pixelSize:         Theme.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
            width:                  entryRoot.menuWidth - 50 - (entry.icon !== "" ? 20 : 0) - (entry.hasChildren ? 16 : 0)
            elide:                  Text.ElideRight
        }

        // Submenu arrow
        Text {
            visible:                entry.hasChildren
            text:                   "›"
            color:                  entryItem.textColor
            font.pixelSize:         Theme.fontSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
