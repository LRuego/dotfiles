pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

Item {
    id: root

    // --- PROPERTIES ---
    property int cpuUsage: 0
    property int memUsagePercent: 0
    property int gpuUsage: 0
    property int vramUsagePercent: 0
    property int cpuTemp: 0
    property int gpuTemp: 0
    property bool gamemodeActive: false

    // --- ICONS ---
    readonly property string cpuIcon: Assets.cpu
    readonly property string memIcon: Assets.ram
    readonly property string gpuIcon: Assets.gpu
    readonly property string vramIcon: Assets.ram

    // --- CPU STATE ---
    property var lastCpu: ({ total: 0, idle: 0 })

    // --- STATS PROCESS ---
    Process {
        id: statsProcess
        command: [
            "bash", "-c", 
            "grep 'cpu ' /proc/stat; " +
            "echo \"STATS:{\\\"mem\\\":$(free | awk '/Mem:/ {print int($3/$2 * 100)}'), " +
            "\\\"gpu\\\":$(cat /sys/class/drm/card1/device/gpu_busy_percent), " +
            "\\\"vru\\\":$(cat /sys/class/drm/card1/device/mem_info_vram_used), " +
            "\\\"vrt\\\":$(cat /sys/class/drm/card1/device/mem_info_vram_total), " +
            "\\\"ct\\\":$(cat /sys/class/hwmon/hwmon4/temp1_input), " +
            "\\\"gt\\\":$(cat /sys/class/hwmon/hwmon1/temp1_input), " +
            "\\\"game\\\":$(gamemoded -s | grep -q 'is active' && echo true || echo false)}\""
        ]
        stdout: SplitParser {
            onRead: function(data) {
                let lines = data.split("\n")
                for (let line of lines) {
                    let trimmed = line.trim()
                    
                    if (trimmed.startsWith("cpu")) {
                        let parts = trimmed.split(/\s+/).filter(s => s.length > 0)
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
                            if (totalDiff > 0) {
                                root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                            }
                        }
                        root.lastCpu = { total: currentTotal, idle: currentIdle }
                    } else if (trimmed.startsWith("STATS:")) {
                        try {
                            let json = JSON.parse(trimmed.substring(6))
                            root.memUsagePercent = json.mem
                            root.gpuUsage = json.gpu
                            root.gamemodeActive = json.game
                            root.cpuTemp = Math.round(json.ct / 1000)
                            root.gpuTemp = Math.round(json.gt / 1000)
                            if (json.vrt > 0) {
                                root.vramUsagePercent = Math.round((json.vru / json.vrt) * 100)
                            }
                        } catch (e) {}
                    }
                }
            }
        }
    }

    // --- REFRESH TIMER ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProcess.running = true
    }
}
