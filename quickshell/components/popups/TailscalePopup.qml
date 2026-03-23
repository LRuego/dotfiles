// components/popups/TailscalePopup.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.components.base
import qs.services.network
import qs.services.system
import qs.services.ui
import qs.core

MenuPopup {
    id: root

    menuWidth:  260

    // --- HEADER ---
    Item {
        width:  parent.width
        height: 36

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing:                10

            IconImage {
                id:          tsIcon
                source:      TailscaleService.active ? Assets.tailscaleOn : Assets.tailscaleOff
                implicitSize: 28
                smooth:      true
                mipmap:      true
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: null

                MouseArea {
                    width:       parent.width
                    height:      parent.height
                    cursorShape: Qt.PointingHandCursor
                    onClicked:   TailscaleService.toggle()
                }
            }

            Column {

                Text {
                    text:           "Tailscale"
                    color:          ThemeState.accent
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold:      true
                }

                Text {
                    text:           TailscaleService.transitioning
                                        ? "Connecting..."
                                        : TailscaleService.active ? "Connected" : "Disconnected"
                    color:          Theme.subtext
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }

    // --- DIVIDER ---
    Rectangle {
        width:   parent.width
        height:  1
        color:   Theme.overlay
        visible: TailscaleService.connected
    }

    // --- PEER LIST ---
    ListView {
        id:      peerList
        width:   parent.width
        visible: TailscaleService.connected
        clip:    true
        spacing: 2

        property int maxVisible: 5
        height: {
            if (count <= maxVisible) return contentHeight
            let item = contentItem.children[0]
            if (!item) return maxVisible * 48
            return (item.height * maxVisible) + (spacing * (maxVisible - 1))
        }

        model: TailscaleService.peers

        delegate: MenuItem {
            id:    peerItem
            width: ListView.view.width

            readonly property string lastSeenStr: {
                if (modelData.online || modelData.lastSeen === "0001-01-01T00:00:00Z") return "Online"
                return Qt.formatDateTime(new Date(modelData.lastSeen), "MMM d, h:mm AP")
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

            onHoveredChanged: {
                if (hovered) {
                    globalTooltip.show(peerItem, lastSeenStr)
                } else {
                    globalTooltip.hide(peerItem)
                }
            }

            Row {
                spacing: 10

                IconLabel {
                    icon:      peerItem.peerIcon
                    iconSize:  20
                    iconWidth: 20
                    colorize:  true
                    iconColor: modelData.online ? Theme.success : Theme.overlay
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 1
                    anchors.verticalCenter: parent.verticalCenter

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

                    Text {
                        text:           modelData.ip
                        color:          Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
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
    MenuItem {
        width: parent.width

        onClicked: (button) => {
            if (button === Qt.LeftButton)
                UtilService.openUrl("https://login.tailscale.com/admin")
        }

        IconLabel {
            icon:      Assets.tailscaleIcon
            iconSize:  Theme.fontSizeSmall
            iconWidth: Theme.fontSizeSmall
            colorize:  true
            iconColor: Theme.subtext
            text:      "Open Admin Console"
            textSize:  Theme.fontSizeSmall
            textColor: Theme.subtext
        }
    }
}
