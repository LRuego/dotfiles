// components/IconLabel.qml
import QtQuick
import "../theme.js" as Theme

Row {
    id: root
    anchors.verticalCenter: parent.verticalCenter

    property color  labelColor:   Theme.text
    property string labelFont:    Theme.fontFamily
    property bool   labelBold:    false
    property int    labelSize:    Theme.fontSize
    property int    labelSpacing: 4

    property string icon:         ""
    property color  iconColor:    labelColor
    property int    iconSize:     labelSize
    property string iconFont:     labelFont
    property bool   iconBold:     labelBold

    property string text:         ""
    property color  textColor:    labelColor
    property int    textSize:     labelSize
    property string textFont:     labelFont
    property bool   textBold:     labelBold


    spacing:                      labelSpacing

    Text {
        id: iconItem
        anchors.baseline: labelItem.baseline

        text: root.icon
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: root.iconSize
        font.bold: textBold
        visible: text !== ""
    }

    Text {
        id: labelItem
        anchors.verticalCenter: parent.verticalCenter

        text: root.text
        color: root.textColor
        font.family: root.textFont
        font.pixelSize: root.textSize
        font.bold: textBold
        visible: text !== ""
    }
}
