// components/base/MarqueeText.qml
import QtQuick

// Single-line Text that scrolls instead of eliding: when it's wider than its box it slides to the end,
// pauses, and slides back. Fits = plain static text. Use it like Text: set width, text, color, font.
Item {
    id: root

    // --- API (mirrors Text) ---
    property alias text:  label.text
    property alias color: label.color
    property alias font:  label.font
    property bool  running: true     // false: stays at the start
    property int   speed:   30       // px per second
    property int   pause:   1500     // ms held at each end

    readonly property bool overflowing: label.implicitWidth > root.width + 1
    readonly property real _overflow:   Math.max(0, label.implicitWidth - root.width)

    implicitWidth:  label.implicitWidth
    implicitHeight: label.implicitHeight
    clip: true

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
    }

    SequentialAnimation {
        id:      scroll
        loops:   Animation.Infinite
        running: root.overflowing && root.running && root.visible

        PauseAnimation  { duration: root.pause }
        NumberAnimation { target: label; property: "x"; to: -root._overflow; duration: root._overflow / root.speed * 1000; easing.type: Easing.InOutSine }
        PauseAnimation  { duration: root.pause }
        NumberAnimation { target: label; property: "x"; to: 0; duration: root._overflow / root.speed * 1000; easing.type: Easing.InOutSine }

        onRunningChanged: if (!running) label.x = 0
    }

    // New text or a resize changes the distance: start over from the beginning.
    on_OverflowChanged: {
        label.x = 0
        if (scroll.running) scroll.restart()
    }
}
