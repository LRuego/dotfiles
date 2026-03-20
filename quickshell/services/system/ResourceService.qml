// services/system/ResourceService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- PROPERTIES ---
    property int  cpuUsage:         0
    property int  memUsagePercent:  0
    property real memUsageGiB:      0
    property int  gpuUsage:         0
    property int  vramUsagePercent: 0
    property real vramUsageGiB:     0
    property int  cpuTemp:          0
    property int  gpuTemp:          0

    // --- CPU STATE ---
    property var lastCpu: ({ total: 0, idle: 0 })

    // --- DYNAMIC PATHS ---
    property string cpuTempPath: ""
    property string gpuTempPath: ""

    Component.onCompleted: findPathsProcess.running = true

    // --- PATH DISCOVERY ---
    Process {
        id: findPathsProcess
        command: ["bash", "-c", "for h in /sys/class/hwmon/hwmon*; do name=$(cat $h/name); if [ \"$name\" == \"k10temp\" ]; then echo \"CPU:$h/temp1_input\"; elif [ \"$name\" == \"amdgpu\" ]; then echo \"GPU:$h/temp1_input\"; fi; done"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("CPU:")) root.cpuTempPath = line.substring(4).trim()
                if (line.startsWith("GPU:")) root.gpuTempPath = line.substring(4).trim()
            }
        }
        onRunningChanged: {
            if (!running) refreshTimer.running = true
        }
    }

    // --- STATS PROCESS ---
    Process {
        id: statsProcess
        command: [
            "bash", "-c",
            "grep 'cpu ' /proc/stat; " +
            "echo \"STATS:{\\\"mem\\\":$(free | awk '/Mem:/ {print int($3/$2 * 100)}'), " +
            "\\\"mu\\\":$(free -b | awk '/Mem:/ {print $3}'), " +
            "\\\"gpu\\\":$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo 0), " +
            "\\\"vru\\\":$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || cat /sys/class/drm/card0/device/mem_info_vram_used 2>/dev/null || echo 0), " +
            "\\\"vrt\\\":$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || cat /sys/class/drm/card0/device/mem_info_vram_total 2>/dev/null || echo 0), " +
            "\\\"ct\\\":$(cat " + root.cpuTempPath + " 2>/dev/null || echo 0), " +
            "\\\"gt\\\":$(cat " + root.gpuTempPath + " 2>/dev/null || echo 0)}\""
        ]
        stdout: SplitParser {
            onRead: data => {
                let lines = data.split("\n")
                for (let line of lines) {
                    let trimmed = line.trim()

                    if (trimmed.startsWith("cpu")) {
                        let parts   = trimmed.split(/\s+/).filter(s => s.length > 0)
                        let user    = parseInt(parts[1])
                        let nice    = parseInt(parts[2])
                        let system  = parseInt(parts[3])
                        let idle    = parseInt(parts[4])
                        let iowait  = parseInt(parts[5])
                        let irq     = parseInt(parts[6])
                        let softirq = parseInt(parts[7])
                        let steal   = parseInt(parts[8]) || 0

                        let currentIdle  = idle + iowait
                        let currentTotal = user + nice + system + idle + iowait + irq + softirq + steal

                        if (root.lastCpu.total !== 0) {
                            let totalDiff = currentTotal - root.lastCpu.total
                            let idleDiff  = currentIdle - root.lastCpu.idle
                            if (totalDiff > 0)
                                root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                        }
                        root.lastCpu = { total: currentTotal, idle: currentIdle }

                    } else if (trimmed.startsWith("STATS:")) {
                        try {
                            let json = JSON.parse(trimmed.substring(6))
                            root.memUsagePercent  = json.mem
                            root.memUsageGiB      = Math.round((json.mu / 1024 / 1024 / 1024) * 10) / 10
                            root.gpuUsage         = json.gpu
                            root.cpuTemp          = Math.round(json.ct / 1000)
                            root.gpuTemp          = Math.round(json.gt / 1000)
                            if (json.vrt > 0) {
                                root.vramUsagePercent = Math.round((json.vru / json.vrt) * 100)
                                root.vramUsageGiB     = Math.round((json.vru / 1024 / 1024 / 1024) * 10) / 10
                            }
                        } catch (e) {}
                    }
                }
            }
        }
    }

    // --- REFRESH TIMER ---
    Timer {
        id:               refreshTimer
        interval:         1000
        running:          false
        repeat:           true
        triggeredOnStart: true
        onTriggered:      statsProcess.running = true
    }
}
