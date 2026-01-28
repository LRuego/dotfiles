// services/ClockService.qml
import QtQuick
import Quickshell

QtObject {
    id: root
    property var _sysClock: SystemClock { precision: SystemClock.Minutes }

    readonly property string time: Qt.formatTime(_sysClock.date, "hh:mm")
    readonly property string date: Qt.formatDate(_sysClock.date, "MM-d")
}
