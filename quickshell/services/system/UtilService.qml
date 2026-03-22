// services/system/UtilService.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    Process {
        id:      clipProc
        property string pending: ""
        command: ["wl-copy", pending]
    }

    function copyToClipboard(text) {
        clipProc.pending = text;
        clipProc.running = true;
    }

    function openUrl(url) {
        Qt.openUrlExternally(url);
    }
}
