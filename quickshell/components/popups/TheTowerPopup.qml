// components/popups/TheTowerPopup.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.components.base
import qs.services.ui
import qs.core

MenuPopup {
    id: root

    menuWidth: 450

    property var logModel: []
    property var _tempModel: []
    property string startTimeStr: ""
    property int    runCount: 0

    Process {
        id: statsProcess
        command: ["bash", "-c", "START_TIME=$(systemctl --user show the-tower-auto-run.service --property=ActiveEnterTimestamp --value); if [ -z \"$START_TIME\" ]; then echo \"{\\\"start\\\": \\\"\\\", \\\"runs\\\": 0}\"; else FORMATTED_TIME=$(date -d \"$START_TIME\" \"+%b %-d, %-I:%M %p\"); RUN_COUNT=$(journalctl --user -u the-tower-auto-run.service --since=\"$START_TIME\" | grep -c \"Previous run took\" || true); echo \"{\\\"start\\\": \\\"$FORMATTED_TIME\\\", \\\"runs\\\": $RUN_COUNT}\"; fi"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    let json = JSON.parse(line.trim())
                    root.startTimeStr = json.start
                    root.runCount = json.runs
                } catch(e) {}
            }
        }
    }

    TextMetrics {
        id: logMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Process {
        id: logProcess
        command: ["bash", "-c", "journalctl --user -u the-tower-auto-run.service -n 100 | grep 'python' | tail -n 50 | sed -E 's/^(.{15}) .*python\\[[0-9]+\\]: /\\1 | /'"]
        stdout: SplitParser {
            onRead: line => {
                let text = line.trim()
                if (text.length > 0) {
                    root._tempModel.push({ text: text })
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                let maxW = 350; // Base minimum width
                if (root._tempModel.length === 0) {
                    root.logModel = [{ text: "No python logs found" }]
                } else {
                    for (let i = 0; i < root._tempModel.length; i++) {
                        logMetrics.text = root._tempModel[i].text
                        if (logMetrics.width > maxW) {
                            maxW = logMetrics.width
                        }
                    }
                    if (maxW > 600) {
                        maxW = 600
                    }
                    root.logModel = root._tempModel
                }
                root.menuWidth = maxW + 40 // Add padding for margins
            }
        }
    }

    onOpenChanged: {
        if (open) {
            root.logModel = [{ text: "Loading logs..." }]
            root._tempModel = []
            logProcess.running = true
            statsProcess.running = true
        }
    }

    // --- HEADER ---
    Item {
        width:  parent.width
        height: 36

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing:                10

            IconLabel {
                icon:      Assets.hexagon
                iconSize:  28
                colorize:  true
                iconColor: ThemeState.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                Text {
                    text:           "The Tower"
                    color:          ThemeState.accent
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold:      true
                }

                Text {
                    text:           root.startTimeStr === "" 
                                        ? "Inactive" 
                                        : "Started: " + root.startTimeStr + "  |  Runs: " + root.runCount
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
    }

    // --- LOG LIST ---
    ListView {
        id:      logListView
        width:   parent.width
        
        property int maxVisible: 5
        height: {
            if (count === 0) return 0;
            if (count <= maxVisible) return contentHeight;
            // Calculate exact height for 5 lines using TextMetrics height
            return (logMetrics.height * maxVisible) + (spacing * (maxVisible - 1));
        }

        clip:    true
        spacing: 4
        model:   root.logModel
        
        onCountChanged: {
            if (count > 0) {
                Qt.callLater(() => {
                    logListView.positionViewAtEnd();
                });
            }
        }
        
        delegate: Text {
            width:          logListView.width
            elide:          Text.ElideRight
            text:           modelData.text
            color:          ThemeState.text
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
