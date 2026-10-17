// components/base/MenuHeaderButton.qml
import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.core
import qs.services.ui

// Icon button for a MenuHeader's right edge.
Item {
    id: root

    property string icon:      ""
    property int    iconSize:  18
    property color  iconColor: Theme.subtext
    property color  hoverColor: ThemeState.accent

    signal clicked(int button)

    implicitWidth:  32
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius:       Theme.cornerRadius
        color:        area.containsMouse ? ThemeState.hover : "transparent"
    }

    IconImage {
        anchors.centerIn: parent
        source:           root.icon
        implicitSize:     root.iconSize
        layer.enabled:    true
        layer.effect: MultiEffect {
            colorization:      1.0
            colorizationColor: area.containsMouse ? root.hoverColor : root.iconColor
        }
    }

    MouseArea {
        id:           area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked:    (mouse) => root.clicked(mouse.button)
    }
}
