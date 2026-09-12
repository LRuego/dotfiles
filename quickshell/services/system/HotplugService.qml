pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.ui

Item {
    id: root

    property var usbDevices: []
    property var storageDevices: []

    // --- TIMERS FOR DEBOUNCING UDEV EVENTS ---
    Timer {
        id: refreshUsbTimer
        interval: 500
        onTriggered: usbQuery.running = true
    }

    Timer {
        id: refreshStorageTimer
        interval: 500
        onTriggered: storageQuery.running = true
    }

    // --- UDEV MONITOR (Persistent Trigger) ---
    Process {
        id: udevMonitor
        command: ["stdbuf", "-oL", "udevadm", "monitor", "--udev", "--subsystem-match=block", "--subsystem-match=usb"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                if (data.includes("block")) refreshStorageTimer.restart()
                if (data.includes("usb")) refreshUsbTimer.restart()
            }
        }
    }

    // --- QUERIES ---
    Process {
        id: usbQuery
        property var tempList: []
        property var tempNames: []
        command: ["sh", "-c", "cat /sys/bus/usb/devices/*/product 2>/dev/null"]
        
        stdout: SplitParser {
            onRead: (line) => {
                let name = line.trim()
                if (name !== "" && !name.includes("xHCI Host Controller")) {
                    usbQuery.tempList.push({ name: name })
                    usbQuery.tempNames.push(name)
                }
            }
        }
        
        onExited: {
            let list = usbQuery.tempList
            let newNames = usbQuery.tempNames
            
            // Compare for Notifications (skip if first run)
            if (root.usbDevices.length > 0) {
                let oldNames = root.usbDevices.map(d => d.name)
                
                for (let name of newNames) {
                    if (!oldNames.includes(name)) {
                        NotificationService.notify("Hardware Connected", "USB Device: " + name, "dialog-information", undefined, undefined, true)
                    }
                }
                for (let name of oldNames) {
                    if (!newNames.includes(name)) {
                        NotificationService.notify("Hardware Disconnected", "USB Device: " + name, "dialog-warning", undefined, undefined, true)
                    }
                }
            }

            root.usbDevices = list
            usbQuery.tempList = []
            usbQuery.tempNames = []
        }
    }

    Process {
        id: storageQuery
        property string jsonBuf: ""
        command: ["lsblk", "-J", "-o", "NAME,LABEL,SIZE,MOUNTPOINTS,RM,TRAN"]
        
        stdout: SplitParser {
            onRead: (line) => {
                storageQuery.jsonBuf += line + "\n"
            }
        }
        
        onExited: {
            let data = storageQuery.jsonBuf
            storageQuery.jsonBuf = ""
            if (data.trim() === "") return
            
            try {
                let parsed = JSON.parse(data)
                let drives = []
                
                if (parsed.blockdevices) {
                    for (let i = 0; i < parsed.blockdevices.length; i++) {
                        let dev = parsed.blockdevices[i]
                        
                        // We only want Removable drives OR USB connected drives
                        if (dev.rm === true || dev.tran === "usb") {
                            // Extract primary mountpoint (if any)
                            let mount = (dev.mountpoints && dev.mountpoints.length > 0 && dev.mountpoints[0] !== null) 
                                        ? dev.mountpoints[0] : ""
                                        
                            drives.push({
                                name: dev.name,
                                label: dev.label ? dev.label : "USB Drive",
                                size: dev.size,
                                mountpoint: mount,
                                isMounted: mount !== ""
                            })
                        }
                    }
                }
                
                // Compare for Notifications
                if (root.storageDevices.length > 0) {
                    let newNames = drives.map(d => d.name)
                    let oldNames = root.storageDevices.map(d => d.name)
                    
                    for (let name of newNames) {
                        if (!oldNames.includes(name)) {
                            let drive = drives.find(d => d.name === name)
                            NotificationService.notify("Storage Connected", drive.label + " (" + drive.size + ")", "drive-removable-media", undefined, undefined, true)
                        }
                    }
                    for (let name of oldNames) {
                        if (!newNames.includes(name)) {
                            let drive = root.storageDevices.find(d => d.name === name)
                            NotificationService.notify("Storage Removed", drive.label + " (" + drive.size + ")", "dialog-warning", undefined, undefined, true)
                        }
                    }
                }
                
                root.storageDevices = drives
                
            } catch (e) {
                console.log("Error parsing lsblk JSON:", e)
            }
        }
    }

    // Initialize on boot
    Component.onCompleted: {
        usbQuery.running = true
        storageQuery.running = true
    }
}
