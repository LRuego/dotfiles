// components/base/ContextMenu.qml
import QtQuick
import Quickshell
import qs.services.ui
import qs.core

PopupWindow {
    id: contextMenuRoot

    // --- API ---
    // For DBus tray menus pass a QsMenuHandle via menuHandle.
    // For custom static menus pass a model array via model.
    property var        menuHandle: null
    property var        model:      []
    property bool       open:       false
    property var        anchorItem: null
    property int        menuWidth:  200

    signal dismissed()
    signal closedAll()

    onDismissed: contextMenuRoot.open = false

    // --- WINDOW CONFIG ---
    anchor {
        item:        contextMenuRoot.anchorItem
        edges:       Edges.Bottom | Edges.Left
        gravity:     Edges.Bottom | Edges.Right
        adjustment:  PopupAdjustment.All
        margins.top: 5
    }

    implicitWidth:  contextMenuRoot.menuWidth
    implicitHeight: contextColumn.implicitHeight + 16 + 5
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
        height:            contextColumn.implicitHeight + 16
        color:             Theme.base
        radius:            Theme.cornerRadius
        border.color:      Theme.overlay
        border.width:      1

        Column {
            id:              contextColumn
            anchors.fill:    parent
            anchors.margins: 8
            spacing:         2

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
                        Rectangle {
                            width:  parent?.width ?? 0
                            height: 1
                            color:  Theme.overlay
                        }
                    }

                    Component {
                        id: staticItemComponent
                        MenuItem {
                            width: parent?.width ?? 0
                            onClicked: (button) => {
                                if (button === Qt.LeftButton && modelData.action) {
                                    modelData.action()
                                    menu.open = false
                                }
                            }
                            IconLabel {
                                icon:      modelData.icon ?? ""
                                colorize:  true
                                iconSize:  Theme.fontSizeSmall
                                iconColor: modelData.enabled !== false ? ThemeState.text : Theme.subtext
                                text:      modelData.text ?? ""
                                textSize:  Theme.fontSizeSmall
                                textColor: modelData.enabled !== false ? ThemeState.text : Theme.subtext
                            }
                        }
                    }
                }
            }
        }
    }
}
