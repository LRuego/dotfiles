// components/menus/TailscaleMenu.qml
import QtQuick
import Quickshell
import "../base"
import "../../services/network"
import "../../services/ui"
import "../../core"

MenuPopup {
    id: root
    
    // Bind to the service state
    open: TailscaleService.menuOpen
    anchorItem: TailscaleService.menuAnchor
    menuWidth: 250

    // React to the global dismissal
    onDismissed: TailscaleService.menuOpen = false

    // --- CONTENT ---
    
    // 1. Header
    Item {
        width: parent.width
        height: 32

        Row {
            anchors.top: parent.top
            spacing: 12

            IconLabel {
                id: tsMenuIcon
                icon: Assets.tailscaleOn 
                iconSize: 32
                iconWidth: 32 
                anchors.top: parent.top
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: -4 
                spacing: 0
                
                Text {
                    text: "Tailscale"
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }
                Text {
                    text: TailscaleService.connected ? "Connected" : "Disconnected"
                    color: Theme.subtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
    
    // 2. Divider
    Rectangle { 
        width: parent.width 
        height: 1 
        color: Theme.overlay 
        visible: TailscaleService.connected
    }

    // 3. Peer List
    ListView {
        width: parent.width
        // SMART HEIGHT
        property int visibleItems: 5
        property int maxListHeight: (36 * visibleItems) + (spacing * (visibleItems - 1))
        
        height: Math.min(maxListHeight, contentHeight)
        model: TailscaleService.peers
        clip: true
        spacing: 4
        visible: TailscaleService.connected

        delegate: MenuItem {
            id: peerItem
            
            readonly property string lastSeenStr: {
                if (modelData.online || modelData.lastSeen === "0001-01-01T00:00:00Z") return "Connected"
                return Qt.formatDateTime(new Date(modelData.lastSeen), "MMM d, h:mm AP")
            }

            readonly property string peerIcon: {
                if (modelData.isSelf) return Assets.desktop
                if (modelData.tags && modelData.tags.indexOf("tag:server") !== -1) return Assets.server
                if (modelData.os === "android" || modelData.os === "iOS") return Assets.smartphone
                return Assets.desktop
            }

            tooltip: "IP: " + modelData.ip + (lastSeenStr !== "Connected" ? "\nLast: " + lastSeenStr : "")
            
            onClicked: (button) => {
                if (button === Qt.LeftButton) {
                    console.log("Clicked peer: " + modelData.name)
                }
            }

            // Call the GLOBAL tooltip instance
            onHoveredChanged: {
                if (hovered && tooltip !== "") {
                  globalTooltip.show(peerItem, tooltip, peerItem.mouseX, peerItem.mouseY, {
                      followCursor: false,
                      direction: Edges.Top,
                      delay: 0
                  });
                } else {
                    globalTooltip.hide(peerItem);
                }
            }

            IconLabel {
                labelSpacing: 12
                icon: peerItem.peerIcon
                iconColor: modelData.online ? Theme.success : Theme.overlay
                colorize: true
                text: modelData.name
                textColor: modelData.isSelf ? ThemeState.accent : ThemeState.text
                textBold: modelData.isSelf
            }
        }
    }
}
