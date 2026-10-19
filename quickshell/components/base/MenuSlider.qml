// components/base/MenuSlider.qml
import QtQuick
import qs.core
import qs.services.ui

// Horizontal 0-1 slider for menu rows: drag, click or scroll; optional live level meter under the track.
Item {
    id: root

    // --- API ---
    property real  value: 0          // from the source; shown unless dragging
    property real  level: -1         // live level 0-1 drawn under the track; < 0 hides it
    property bool  dimmed: false     // e.g. muted: greys the fill instead of the accent
    property real  step:  0.05       // per wheel notch
    property color fillColor: root.dimmed ? Theme.subtext : ThemeState.accent

    signal moved(real value)

    readonly property bool dragging: area.pressed
    // While dragging, show the pointer's value rather than waiting for the source to echo it back.
    property real _dragValue: 0
    readonly property real shown: Math.max(0, Math.min(1, root.dragging ? root._dragValue : root.value))

    implicitHeight: 14

    function _clamp(v) { return Math.max(0, Math.min(1, v)) }

    // --- TRACK ---
    Rectangle {
        id:     track
        width:  parent.width
        height: 4
        radius: 2
        anchors.verticalCenter: parent.verticalCenter
        color:  Theme.overlay

        Rectangle {
            width:  track.width * root.shown
            height: parent.height
            radius: parent.radius
            color:  root.fillColor
        }
    }

    // --- LEVEL METER ---
    Rectangle {
        visible:        root.level >= 0
        anchors.top:    track.bottom
        anchors.topMargin: 2
        height:         2
        radius:         1
        width:          track.width * Math.min(1, Math.max(0, root.level))
        color:          Theme.success
        opacity:        0.7

        Behavior on width { NumberAnimation { duration: 60 } }
    }

    // --- KNOB ---
    Rectangle {
        width:   12
        height:  12
        radius:  6
        x:       track.width * root.shown - width / 2
        anchors.verticalCenter: track.verticalCenter
        color:   root.fillColor
        border.color: Theme.base
        border.width: 2
        scale:   area.containsMouse || root.dragging ? 1 : 0

        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
    }

    // --- INPUT ---
    MouseArea {
        id:              area
        anchors.fill:    parent
        anchors.margins: -4 // a little extra reach around the thin track
        hoverEnabled:    true
        preventStealing: true // keeps a scrolling list from taking the drag
        cursorShape:     Qt.PointingHandCursor

        function _at(x) { return root._clamp((x + anchors.margins) / track.width) }

        onPressed:         (mouse) => { root._dragValue = _at(mouse.x); root.moved(root._dragValue) }
        onPositionChanged: (mouse) => { if (pressed) { root._dragValue = _at(mouse.x); root.moved(root._dragValue) } }
        onWheel:           (wheel) => root.moved(root._clamp(root.value + (wheel.angleDelta.y > 0 ? root.step : -root.step)))
    }
}
