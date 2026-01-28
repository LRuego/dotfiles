// components/ModuleDivider.qml
import QtQuick
import "../theme.js" as Theme

Rectangle {
    id: root
    property color    divColor: Theme.overlay
    property int      divWidth: 1

    color:            root.divColor
    height:           parent.height
    width:            root.divWidth
}
