// components/menus/BluetoothMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.components.base
import qs.services.network
import qs.services.ui

Menu {
    id: root

    menuWidth: 300
    padded:    false

    // Scanning is manual only — stop and forget results when the popup closes.
    property bool hasScanned: false

    onVisibleChanged: {
        if (!visible) {
            BluetoothService.stopDiscovery()
            root.hasScanned = false
        }
    }

    function scan() {
        BluetoothService.startDiscovery()
        root.hasScanned = true
    }

    // --- HEADER ---
    MenuHeader {
        icon:          !BluetoothService.powered
                           ? Assets.bluetoothOff
                           : (BluetoothService.connected ? Assets.bluetoothConnected : Assets.bluetooth)
        colorize:      true
        iconColor:     !BluetoothService.powered
                           ? Theme.subtext
                           : (BluetoothService.connected ? ThemeState.accent : ThemeState.text)
        iconClickable: true
        onIconClicked: BluetoothService.togglePower()

        title:    "Bluetooth"
        subtitle: !BluetoothService.powered ? "Off" : (BluetoothService.connected ? "Connected" : "On")
    }

    // --- DIVIDER ---
    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- MY DEVICES SECTION ---
    // spacing:0 — MenuSectionLabel and the row list own their own breathing room.
    Column {
        width:   parent.width
        spacing: 0
        visible: BluetoothService.powered

        MenuSectionLabel {
            text: "My Devices"
        }

        Text {
            leftPadding:    12
            bottomPadding:  8
            visible:        BluetoothService.savedDevices.length === 0
            text:           "No saved devices"
            color:          Theme.subtext
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        MenuList {
            spacing:    0
            maxVisible: 5
            model:      BluetoothService.savedDevices

            delegate: MenuItem {
                id:    deviceItem
                width: ListView.view.width
                implicitHeight: 54
                radius: 0 // full-bleed row, no inset corners to round

                // Connected reads as "always hovered" — one less state for the eye to learn.
                active: modelData.connected

                onClicked: (button) => {
                    if (button === Qt.LeftButton) {
                        if (modelData.connected) {
                            modelData.disconnect()
                            modelData.blocked = true // stops devices that aggressively self-reconnect
                        } else {
                            modelData.blocked = false
                            modelData.connect()
                        }
                    } else if (button === Qt.RightButton) {
                        // Always (re)shows at the cursor — close first so an open popup remaps cleanly.
                        let mx = deviceItem.mouseX
                        let my = deviceItem.mouseY
                        deviceMenu.open = false
                        Qt.callLater(() => {
                            deviceMenu.anchorX = mx
                            deviceMenu.anchorY = my
                            deviceMenu.open    = true
                        })
                    }
                }

                ContextMenu {
                    id:         deviceMenu
                    anchorItem: deviceItem
                    menuWidth:  170
                    model: [
                        { text: "Auto-Connect",  checked: modelData.trusted, closeOnClick: false,
                        action: () => modelData.trusted = !modelData.trusted },
                        { text: "Forget Device", disabled: true, action: () => modelData.forget() }
                    ]
                }

                RowLayout {
                    width:   parent.width
                    spacing: 10

                    IconLabel {
                        icon:      BluetoothService.deviceIcon(modelData)
                        iconSize:  20
                        colorize:  true
                        iconColor: deviceItem.active ? ThemeState.accent : Theme.subtext
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text:    modelData.name || modelData.deviceName
                            color:   deviceItem.active ? ThemeState.accent : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            elide:   Text.ElideRight
                            width:   parent.width
                        }

                        // Absolute positioning, not a joined string — keeps the bullet at a fixed x.
                        Item {
                            width:  parent.width
                            height: statusText.implicitHeight

                            Text {
                                id: statusText
                                anchors.left:           parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text:  deviceItem.active ? "Connected" : "Not Connected"
                                color: deviceItem.active ? Theme.success : Theme.subtext
                                font.family: Theme.fontFamilyAlt
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusBullet
                                visible:                  modelData.batteryAvailable
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter:   parent.verticalCenter
                                text:  "•"
                                color: Theme.overlay
                                font.family: Theme.fontFamilyAlt
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Text {
                                visible:                 modelData.batteryAvailable
                                anchors.left:            statusBullet.right
                                anchors.leftMargin:      6
                                anchors.right:           parent.right
                                anchors.verticalCenter:  parent.verticalCenter
                                horizontalAlignment:     Text.AlignHCenter
                                text:  Math.round(modelData.battery * 100) + "%"
                                color: deviceItem.active ? Theme.success : Theme.subtext
                                font.family: Theme.fontFamilyAlt
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }
                        }
                    }

                }
            }
        }
    }

    // --- DIVIDER ---
    Rectangle {
        width:   parent.width
        height:  1
        color:   Theme.overlay
        visible: BluetoothService.powered
    }

    // --- AVAILABLE DEVICES SECTION ---
    // Always shown like "My Devices" — the footer indicates scan state.
    Column {
        width:   parent.width
        spacing: 0
        visible: BluetoothService.powered

        MenuSectionLabel {
            visible: root.hasScanned && BluetoothService.availableDevices.length > 0
            text:    "Available Devices"
        }

        MenuList {
            spacing:    0
            maxVisible: 5
            model:      root.hasScanned ? BluetoothService.availableDevices : []

            delegate: MenuItem {
                width: ListView.view.width
                implicitHeight: 46
                hoverColor: Theme.surface1
                radius: 0 // full-bleed row, no inset corners to round

                RowLayout {
                    width:   parent.width
                    spacing: 10

                    IconLabel {
                        icon:      BluetoothService.deviceIcon(modelData)
                        iconSize:  20
                        colorize:  true
                        iconColor: Theme.subtext
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text:    modelData.name
                        color:   Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        elide:   Text.ElideRight
                    }

                    Rectangle {
                        visible: !modelData.pairing
                        Layout.preferredWidth:  56
                        Layout.preferredHeight: 26
                        radius:  Theme.cornerRadius
                        color:   pairMouse.containsMouse ? ThemeState.hover : Theme.overlay

                        Text {
                            anchors.centerIn: parent
                            text:  "Pair"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                        }

                        MouseArea {
                            id: pairMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    modelData.pair()
                        }
                    }

                    Text {
                        visible: modelData.pairing
                        text:    "Pairing…"
                        color:   Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
        }
    }

    // --- DIVIDER ---
    // Only when Available Devices has content — avoids a doubled-up line before the footer.
    Rectangle {
        width:   parent.width
        height:  1
        color:   Theme.overlay
        visible: BluetoothService.powered && root.hasScanned && BluetoothService.availableDevices.length > 0
    }

    // --- FOOTER ---
    // Always the true last element — the only thing that needs bottom-corner rounding.
    MenuFooter {
        visible: BluetoothService.powered
        // Discovery has no timeout — reflects live scan state, not "has scanned ever".
        label:   BluetoothService.discovering ? "Scanning…" : "Scan for Devices"
        onActivated: root.scan()
    }
}
