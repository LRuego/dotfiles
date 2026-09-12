import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.components.base
import qs.services.system
import qs.services.ui

MenuPopup {
    id: root

    menuWidth: 340

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

    // --- STORAGE SECTION ---
    Column {
        width: parent.width
        spacing: 8
        visible: HotplugService.storageDevices.length > 0

        Text {
            text: "Storage Drives"
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
        }

        Repeater {
            model: HotplugService.storageDevices
            
            Rectangle {
                width: parent.width
                height: 54
                color: Theme.surface0
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    
                    IconLabel {
                        icon: "image://icon/drive-removable-media"
                        iconSize: 24
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
                            font.pixelSize: Theme.fontSize
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Text {
                            text: modelData.size + (modelData.isMounted ? " • Mounted" : " • Unmounted")
                            color: Theme.subtext
                            font.family: Theme.fontFamilyAlt
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: ejectMouse.containsMouse ? Theme.surface1 : "transparent"
                        radius: 4
                        
                        IconLabel {
                            anchors.centerIn: parent
                            icon: "image://icon/media-eject"
                            iconSize: 16
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
    
    // Divider
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.overlay
        visible: HotplugService.storageDevices.length > 0 && HotplugService.usbDevices.length > 0
    }

    // --- USB PERIPHERALS SECTION ---
    Column {
        width: parent.width
        spacing: 8
        visible: HotplugService.usbDevices.length > 0

        Text {
            text: "Connected Peripherals"
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
        }

        Repeater {
            model: HotplugService.usbDevices
            
            RowLayout {
                width: parent.width
                spacing: 12
                
                IconLabel {
                    icon: Assets.usb
                    iconSize: 16
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
