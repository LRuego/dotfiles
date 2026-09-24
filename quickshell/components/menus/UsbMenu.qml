// components/menus/UsbMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.components.base
import qs.services.system
import qs.services.ui

Menu {
    id: root

    menuWidth: 300
    padded:    false

    // Eject command executor
    Process {
        id: ejectProcess
        property string target: ""
        command: ["udisksctl", "unmount", "-b", "/dev/" + target]
        onExited: {
            powerOffProcess.target = target;
            powerOffProcess.running = true;
        }
    }
    
    Process {
        id: powerOffProcess
        property string target: ""
        command: ["udisksctl", "power-off", "-b", "/dev/" + target]
        onExited: NotificationService.notify("Safe to Remove", "The drive can now be unplugged.", "dialog-information")
    }

    readonly property int deviceCount: UsbService.storageDevices.length + UsbService.peripherals.length

    // --- HEADER ---
    MenuHeader {
        icon:  Assets.usb
        title: "USB"
        subtitle: root.deviceCount === 1 ? "1 device connected" : root.deviceCount + " devices connected"
    }

    // --- DIVIDER ---
    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- EMPTY STATE ---
    Text {
        width:          parent.width
        visible:        root.deviceCount === 0
        text:           "No devices connected"
        color:          Theme.subtext
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        topPadding:     8
        bottomPadding:  8
    }

    // --- STORAGE SECTION ---
    // spacing:0 — cards get their own inner Column with spacing:8 for mutual gaps.
    Column {
        width: parent.width
        spacing: 0
        visible: UsbService.storageDevices.length > 0

        MenuSectionLabel {
            text: "Storage Drives"
        }

        MenuList {
            spacing:    8
            maxVisible: 5
            model:      UsbService.storageDevices

            delegate: MenuItem {
                width: ListView.view.width
                implicitHeight: 54
                color: hovered ? hoverColor : Theme.surface0
                radius: 0

                RowLayout {
                    width:   parent.width
                    spacing: 12
                    
                    IconLabel {
                        icon: Assets.hardDrive
                        iconSize: 20
                        colorize: true
                        iconColor: ThemeState.accent
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            text: modelData.label || "USB Drive"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Text {
                            text: modelData.size
                            color: Theme.subtext
                            font.family: Theme.fontFamilyAlt
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        color: ejectMouse.containsMouse ? Theme.surface1 : "transparent"
                        radius: 4
                        
                        IconLabel {
                            anchors.centerIn: parent
                            icon: Assets.eject
                            iconSize: 12
                            colorize: true
                            iconColor: Theme.text
                        }
                        
                        MouseArea {
                            id: ejectMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ejectProcess.target = modelData.name
                                ejectProcess.running = true
                                NotificationService.notify("Ejecting", "Safely unmounting drive...", "dialog-information")
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
        visible: UsbService.storageDevices.length > 0 && UsbService.peripherals.length > 0
    }

    // --- USB PERIPHERALS SECTION ---
    // spacing:0 — MenuSectionLabel and the flush row list own their own breathing room.
    Column {
        width: parent.width
        spacing: 0
        visible: UsbService.peripherals.length > 0

        MenuSectionLabel {
            text: "Connected Peripherals"
        }

        MenuList {
            id:         peripheralList
            spacing:    0
            maxVisible: 5
            model:      UsbService.peripherals

            delegate: MenuItem {
                width: ListView.view.width
                radius: 0 // full-bleed row, no inset corners to round
                // Last row is the actual bottom of the popup — round to match, like MenuFooter.
                readonly property bool isLast: index === peripheralList.count - 1
                bottomLeftRadius:  isLast ? Theme.cornerRadius : 0
                bottomRightRadius: isLast ? Theme.cornerRadius : 0

                RowLayout {
                    width:   parent.width
                    spacing: 12

                    IconLabel {
                        icon: Assets.usb
                        iconSize: 20
                        colorize: true
                        iconColor: Theme.subtext
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
