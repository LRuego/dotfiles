pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int cpuUsage: 0
    property int memUsagePercent: 0

    // Internal state for CPU calculation
    property var lastCpu: ({ total: 0, idle: 0 })

    Process {
        id: statsProcess
        // CPU: /proc/stat snapshot
        // RAM: free command calculation
        command: ["bash", "-c", "grep 'cpu ' /proc/stat; free | awk '/Mem:/ { print $3/$2 * 100 }'"]
        stdout: SplitParser {
            onRead: function(data) {
                if (data.startsWith("cpu")) {
                    let parts = data.split(/\s+/).filter(s => s.length > 0)
                    let user = parseInt(parts[1])
                    let nice = parseInt(parts[2])
                    let system = parseInt(parts[3])
                    let idle = parseInt(parts[4])
                    let iowait = parseInt(parts[5])
                    let irq = parseInt(parts[6])
                    let softirq = parseInt(parts[7])
                    let steal = parseInt(parts[8]) || 0

                    let currentIdle = idle + iowait
                    let currentTotal = user + nice + system + idle + iowait + irq + softirq + steal
                    
                    if (root.lastCpu.total !== 0) {
                        let totalDiff = currentTotal - root.lastCpu.total
                        let idleDiff = currentIdle - root.lastCpu.idle
                        // Guard against division by zero
                        if (totalDiff > 0) {
                            root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                        }
                    }
                    root.lastCpu = { total: currentTotal, idle: currentIdle }
                } else if (data.trim() !== "") {
                    let val = parseFloat(data.trim())
                    if (!isNaN(val)) {
                        root.memUsagePercent = Math.round(val)
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProcess.running = true
    }
}
