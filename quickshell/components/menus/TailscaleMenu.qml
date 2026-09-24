// components/menus/TailscaleMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components.base
import qs.services.network
import qs.services.system
import qs.services.ui
import qs.core

Menu {
    id: root

    menuWidth:  300
    padded:     false

    // --- HEADER ---
    MenuHeader {
        icon:          TailscaleService.active ? Assets.tailscaleOn : Assets.tailscaleOff
        iconClickable: true
        pulsing:       TailscaleService.transitioning
        onIconClicked: TailscaleService.toggle()

        title:    "Tailscale"
        subtitle: TailscaleService.transitioning
                      ? "Connecting..."
                      : (TailscaleService.active ? "Connected" : "Disconnected")
    }

    // --- DIVIDER ---
    Rectangle {
        width:   parent.width
        height:  1
        color:   Theme.overlay
        visible: TailscaleService.connected
    }

    // --- PEER LIST ---
    MenuSectionLabel {
        visible: TailscaleService.connected
        text:    "Tailnet"
    }

    MenuList {
        id:      peerList
        visible: TailscaleService.connected
        spacing: 0

        model: TailscaleService.peers

        delegate: MenuItem {
            id:    peerItem
            width: ListView.view.width
            radius: 0 // full-bleed row, no inset corners to round

            readonly property string lastSeenStr: {
                if (modelData.online || modelData.lastSeen === "0001-01-01T00:00:00Z") return ""
                return Qt.formatDateTime(new Date(modelData.lastSeen), "MM/dd/yyyy HH:mm")
            }

            readonly property string peerIcon: {
                if (modelData.isSelf) return Assets.desktop
                if (modelData.tags && modelData.tags.indexOf("tag:server") !== -1) return Assets.server
                if (modelData.os === "android" || modelData.os === "iOS") return Assets.smartphone
                return Assets.desktop
            }

            onClicked: (button) => {
                if (button === Qt.LeftButton) {
                    UtilService.copyToClipboard(modelData.ip)
                    NotificationService.notify(
                        "Tailscale",
                        "Copied " + modelData.ip,
                        Assets.tailscaleIcon,
                        1500,
                        "",
                        true
                    )
                }
            }

            RowLayout {
                width:   parent.width
                spacing: 10

                IconLabel {
                    icon:      peerItem.peerIcon
                    iconSize:  20
                    iconWidth: 20
                    colorize:  true
                    iconColor: modelData.online ? Theme.success : Theme.overlay
                    Layout.alignment: Qt.AlignVCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 1

                    Row {
                        spacing: 6

                        Text {
                            text:           modelData.name
                            color:          modelData.isSelf ? ThemeState.accent : ThemeState.text
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold:      modelData.isSelf
                        }

                        Rectangle {
                            visible:                modelData.isExitNode
                            width:                  exitLabel.implicitWidth + 6
                            height:                 exitLabel.implicitHeight + 2
                            radius:                 height / 2
                            color:                  modelData.isActiveExitNode ? ThemeState.accent : Theme.overlay
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id:               exitLabel
                                anchors.centerIn: parent
                                text:             "exit"
                                color:            modelData.isActiveExitNode ? Theme.base : Theme.subtext
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSizeTiny
                                font.bold:        true
                            }
                        }
                    }

                    // Absolute positioning, not a fill-weighted RowLayout — keeps the bullet at a fixed x.
                    Item {
                        width:  parent.width
                        height: ipText.implicitHeight

                        Text {
                            id: ipText
                            anchors.left:           parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text:           modelData.ip
                            color:          Theme.subtext
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            elide:          Text.ElideRight
                        }

                        Text {
                            id: bulletText
                            visible:                   peerItem.lastSeenStr !== ""
                            anchors.horizontalCenter:  parent.horizontalCenter
                            anchors.verticalCenter:    parent.verticalCenter
                            text:           "•"
                            color:          Theme.overlay
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                        }

                        Text {
                            visible:                 peerItem.lastSeenStr !== ""
                            anchors.left:            bulletText.right
                            anchors.leftMargin:      6
                            anchors.right:           parent.right
                            anchors.verticalCenter:  parent.verticalCenter
                            horizontalAlignment:     Text.AlignHCenter
                            text:           peerItem.lastSeenStr
                            color:          Theme.subtext
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            elide:          Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    // --- DIVIDER ---
    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- FOOTER ---
    MenuFooter {
        icon:  Assets.tailscaleIcon
        label: "Open Admin Console"
        onActivated: UtilService.openUrl("https://login.tailscale.com/admin")
    }
}
