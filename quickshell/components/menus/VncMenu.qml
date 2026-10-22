// components/menus/VncMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.components.base
import qs.services.network
import qs.services.ui

// wayvnc: on/off, what gets captured, who's connected.
Menu {
    id: root

    menuWidth: 300
    padded:    false

    // "All monitors" first, then each screen.
    readonly property var captureOptions: [{ key: "all", title: "All monitors", detail: "Every screen, side by side" }]
        .concat(Quickshell.screens.map(s => ({ key: s.name, title: s.name, detail: `${s.width}×${s.height}` })))

    // --- HEADER ---
    MenuHeader {
        icon:          Assets.vnc
        colorize:      true
        iconColor:     !VncService.active ? Theme.subtext
                           : (VncService.clients.length > 0 ? ThemeState.accent : ThemeState.text)
        iconClickable: true
        onIconClicked: VncService.toggle()
        pulsing:       VncService.transitioning

        title:    "VNC"
        subtitle: {
            if (!VncService.active) return "Off"
            let n = VncService.clients.length
            if (n > 0) return `${n} viewer${n === 1 ? "" : "s"} connected`
            return `Listening on ${VncService.endpoint}`
        }
    }

    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- CAPTURE ---
    // Adjustable while off too: it's saved for the next start.
    MenuSectionLabel {
        text: "Capture"
    }

    Repeater {
        model: root.captureOptions

        delegate: MenuItem {
            id:     captureItem
            radius: 0
            implicitHeight: 44
            active: VncService.capture === modelData.key
            onClicked: (button) => { if (button === Qt.LeftButton) VncService.setCapture(modelData.key) }

            RowLayout {
                width:   parent.width
                spacing: 10

                IconLabel {
                    icon:      Assets.desktop
                    iconSize:  18
                    colorize:  true
                    iconColor: captureItem.active ? ThemeState.accent : Theme.subtext
                    Layout.alignment: Qt.AlignVCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text:           modelData.title
                        color:          captureItem.active ? ThemeState.accent : Theme.text
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    Text {
                        text:           modelData.detail
                        color:          Theme.subtext
                        font.family:    Theme.fontFamilyAlt
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
        }
    }

    // Only matters with someone watching: those switches restart wayvnc.
    Text {
        visible:        VncService.clients.length > 0
        width:          parent.width
        leftPadding:    12
        rightPadding:   12
        topPadding:     4
        bottomPadding:  6
        wrapMode:       Text.WordWrap
        text:           "Switching to or from All monitors reconnects viewers."
        color:          Theme.subtext
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeTiny
    }

    // --- VIEWERS ---
    Rectangle {
        visible: VncService.active
        width:   parent.width
        height:  1
        color:   Theme.overlay
    }

    MenuSectionLabel {
        visible: VncService.active
        text:    "Viewers"
    }

    Text {
        visible:        VncService.active && VncService.clients.length === 0
        leftPadding:    12
        bottomPadding:  8
        text:           "No one connected"
        color:          Theme.subtext
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
        // Keyed by wayvnc's client id so updates don't recreate rows (stale hover).
        model: ScriptModel { values: VncService.active ? VncService.clients : []; objectProp: "id" }

        delegate: MenuItem {
            id:     clientItem
            radius: 0
            implicitHeight: 44

            readonly property var peer: VncService.peerFor(modelData.address)

            RowLayout {
                width:   parent.width
                spacing: 10

                IconLabel {
                    icon:      clientItem.peer && (clientItem.peer.os === "android" || clientItem.peer.os === "iOS")
                                   ? Assets.smartphone : Assets.desktop
                    iconSize:  18
                    colorize:  true
                    iconColor: ThemeState.accent
                    Layout.alignment: Qt.AlignVCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text:           VncService.clientName(modelData)
                        color:          Theme.text
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    Text {
                        visible:        clientItem.peer !== null
                        text:           modelData.address
                        color:          Theme.subtext
                        font.family:    Theme.fontFamilyAlt
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }

                MenuHeaderButton {
                    implicitWidth:  26
                    implicitHeight: 26
                    Layout.alignment: Qt.AlignVCenter
                    icon:       Assets.disconnect
                    iconSize:   16
                    hoverColor: Theme.urgent
                    onClicked:  (button) => VncService.disconnect(modelData.id)
                }
            }
        }
    }

    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- FOOTER ---
    MenuFooter {
        icon:  Assets.vnc
        label: VncService.endpoint ? `Copy address (${VncService.endpoint})` : "Copy address"
        onActivated: VncService.copyAddress()
    }
}
