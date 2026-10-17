// components/base/ContextMenu.qml
import QtQuick
import Quickshell
import qs.services.ui
import qs.core

PopupWindow {
    id: contextMenuRoot

    // --- API ---
    // menuHandle: DBus tray menus. model: custom static menus.
    property var        menuHandle: null
    property var        model:      []
    property bool       open:       false
    property var        anchorItem: null
    property int        menuWidth:  200
    // Set both (>=0) to anchor at a point within anchorItem instead of its
    // whole bounding box — for right-click menus that should open at the cursor.
    property real       anchorX:    -1
    property real       anchorY:    -1

    signal dismissed()
    signal closedAll()

    onDismissed: contextMenuRoot.open = false

    // Opening this one closes whatever other ContextMenu was open, anywhere in the shell.
    onOpenChanged: {
        if (open) FocusService.requestContextMenuOpen(contextMenuRoot)
        else FocusService.clearContextMenu(contextMenuRoot)
    }

    // --- WINDOW CONFIG ---
    anchor {
        item:        contextMenuRoot.anchorItem
        edges:       Edges.Bottom | Edges.Left
        gravity:     Edges.Bottom | Edges.Right
        adjustment:  PopupAdjustment.All
        margins.top: 5

        rect: {
            if (!anchorItem) return Qt.rect(0, 0, 0, 0)
            if (contextMenuRoot.anchorX >= 0 && contextMenuRoot.anchorY >= 0)
                return Qt.rect(contextMenuRoot.anchorX, contextMenuRoot.anchorY, 1, 1)
            return Qt.rect(0, 0, anchorItem.width, anchorItem.height)
        }
    }

    implicitWidth:  contextMenuRoot.menuWidth
    implicitHeight: contextColumn.implicitHeight + 10 + 5
    visible:        open && anchorItem !== null
    color:          "transparent"

    // --- FOCUS ---
    Timer {
        id:          focusDelay
        interval:    50
        onTriggered: FocusService.registerMenu(contextMenuRoot)
    }

    onVisibleChanged: {
        if (visible) {
            focusDelay.start()
        } else {
            focusDelay.stop()
            FocusService.unregisterMenu(contextMenuRoot)
        }
    }

    // Opens the DBus menu entries via QsMenuOpener
    QsMenuOpener {
        id:   menuOpener
        menu: contextMenuRoot.open ? contextMenuRoot.menuHandle : null
    }

    // --- VISUALS ---
    Rectangle {
        anchors.top:       parent.top
        anchors.left:      parent.left
        anchors.right:     parent.right
        anchors.topMargin: 5
        height:            contextColumn.implicitHeight + 10
        // Same translucent panel as NotificationCenter; Hyprland blurs popups behind it.
        color:             Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.8)
        radius:            Theme.cornerRadius
        border.color:      ThemeState.border
        border.width:      1

        Column {
            id:              contextColumn
            anchors.fill:    parent
            anchors.margins: 5
            spacing:         0

            // DBus menu entries
            Repeater {
                model: contextMenuRoot.menuHandle ? menuOpener.children : []

                delegate: ContextMenuEntry {
                    required property var modelData
                    readonly property var menu: contextMenuRoot
                    width:     contextColumn.width
                    entry:     modelData
                    menuWidth: menu.menuWidth
                    onCloseAll: {
                        menu.open = false
                        menu.closedAll()
                    }
                }
            }

            // Static model entries
            Repeater {
                model: contextMenuRoot.menuHandle ? [] : contextMenuRoot.model

                delegate: Loader {
                    required property var modelData
                    readonly property var menu: contextMenuRoot
                    width: contextColumn.width

                    sourceComponent: modelData.separator ? separatorComponent : staticItemComponent

                    Component {
                        id: separatorComponent
                        Item {
                            width:  parent?.width ?? 0
                            height: 9

                            Rectangle {
                                anchors.centerIn: parent
                                width:            parent.width - 20
                                height:           1
                                color:            Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.12)
                            }
                        }
                    }

                    Component {
                        id: staticItemComponent
                        MenuItem {
                            id:    staticEntryItem
                            width: parent?.width ?? 0
                            implicitHeight: 22
                            contentSpacing: 4
                            radius:         5
                            onClicked: (button) => {
                                if (button === Qt.LeftButton && modelData.action) {
                                    modelData.action()
                                    if (modelData.closeOnClick !== false) menu.open = false
                                }
                            }
                            // Entry color vocabulary: inactive->subtext, hovered->base on the accent pill, disabled-on-hover->urgent text.
                            readonly property color entryColor: {
                                if (modelData.enabled === false) return Theme.subtext
                                if (modelData.disabled && staticEntryItem.hovered) return Theme.urgent
                                if (staticEntryItem.hovered) return Theme.base
                                return ThemeState.text
                            }
                            // Destructive entries keep a neutral pill so the red text stays readable.
                            hoverColor: modelData.disabled ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10) : ThemeState.accent

                            // macOS-style checkmark gutter, always reserved so labels line up.
                            Text {
                                width:          14
                                text:           modelData.checked ? "✓" : ""
                                color:          staticEntryItem.entryColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold:      true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconLabel {
                                icon:      modelData.icon ?? ""
                                colorize:  true
                                iconSize:  Theme.fontSizeSmall
                                iconColor: staticEntryItem.entryColor
                                text:      modelData.text ?? ""
                                textSize:  Theme.fontSizeSmall
                                textColor: staticEntryItem.entryColor
                            }
                        }
                    }
                }
            }
        }
    }
}
