// components/IconLabel.qml
import QtQuick
import "../theme.js" as Theme

Row {
    id: root
    anchors.verticalCenter: parent.verticalCenter

    property color  labelColor:   Theme.text
    property bool   labelBold:    false
    property int    labelSize:    Theme.fontSize
    property int    labelSpacing: 4

    property string icon:         ""
    property color  iconColor:    labelColor
    property int    iconSize:     labelSize
    property int    iconWidth:    0
    property string iconFont:     Theme.fontFamilyAlt
    property bool   iconBold:     labelBold
    property int    iconOffset:   0

    property string text:         ""
    property color  textColor:    labelColor
    property int    textSize:     labelSize
    property int    textWidth:    0
    property string textFont:     Theme.fontFamily
    property bool   textBold:     labelBold
    property int    textOffset:   1


    spacing:                      labelSpacing

    readonly property bool isImageIcon: icon.includes(".") || icon.includes("/")

    Image {
        id: imageIconItem
        source: isImageIcon ? (icon.startsWith("/") ? "file://" + icon : icon) : ""

        width: root.iconWidth > 0 ? root.iconWidth : root.iconSize
        height: root.iconSize

        sourceSize.width: width
        sourceSize.height: height

        fillMode: Image.PreserveAspectFit
        visible: isImageIcon && icon !== ""

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.iconOffset
    }

    Text {
        id: iconItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.iconOffset

        text: root.icon
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: root.iconSize
        font.bold: root.iconBold
        visible: !isImageIcon && text !== ""

        width: root.iconWidth > 0 ? root.iconWidth : implicitWidth
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: labelItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.textOffset

        text: root.text
        color: root.textColor
        font.family: root.textFont
        font.pixelSize: root.textSize
        font.bold: root.textBold
        visible: text !== ""

        width: root.textWidth > 0 ? root.textWidth : implicitWidth
        horizontalAlignment: Text.AlignHCenter
    }
}
