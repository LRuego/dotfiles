// components/base/ModuleDivider.qml
import QtQuick
import qs.core

Rectangle {
    id: root
    property color    divColor: Theme.overlay
    property int      divWidth: 1

    color:            root.divColor
    height:           parent.height
    width:            root.divWidth
}
