// services/system/ClockService.qml
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root
    property var _sysClock: SystemClock { precision: SystemClock.Minutes }

    readonly property string time: Qt.formatTime(_sysClock.date, "hh:mm")
    readonly property string date: Qt.formatDate(_sysClock.date, "MM-dd")
    readonly property string fullDate: Qt.formatDate(_sysClock.date, "MM/dd/yyyy")
    readonly property string utcTime: {
        let d = _sysClock.date;
        return d.getUTCHours().toString().padStart(2, '0') + ":" + d.getUTCMinutes().toString().padStart(2, '0') + " UTC";
    }
}
