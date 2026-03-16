// components/IconLabel.qml
import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "../../core"

Row {
    id: root

    // We do NOT anchor the Row itself to verticalCenter.
    // This allows the Row to be used inside Columns without crashing.

    property color  labelColor:   Theme.text
    property bool   labelBold:    false
    property int    labelSize:    Theme.fontSize
    property int    labelSpacing: 4

    property string icon:         ""
    property color  iconColor:    labelColor
    property bool   colorize:     false
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
    property int    elide:        Text.ElideNone

    spacing:                      labelSpacing

    readonly property bool isImageIcon: icon.includes(".") || icon.includes("/")
    readonly property bool isThemeIcon: icon !== "" && !isImageIcon && icon.length > 3

    // ONLY ONE ICONIMAGE
    IconImage {
        id: imageIconItem
        
        source: isImageIcon ? root.icon : (isThemeIcon ? "image://icon/" + root.icon : "")
        
        implicitSize: root.iconWidth > 0 ? root.iconWidth : root.iconSize
        
        visible: (isImageIcon || isThemeIcon) && root.icon !== ""
        
        // This keeps the ICON vertically centered relative to the Row's height
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.iconOffset

        layer.enabled: visible && root.colorize && root.iconColor.a > 0
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.iconColor
        }
    }

    // FONT-BASED ICONS (Nerd Font)
    Text {
        id: iconItem
        // This keeps the ICON vertically centered relative to the Row's height
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.iconOffset
        
        text: (!isImageIcon && !isThemeIcon) ? root.icon : ""
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: root.iconSize
        font.bold: root.iconBold
        visible: text !== ""
        
        width: root.iconWidth > 0 ? root.iconWidth : implicitWidth
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // --- THE LABEL ---
    Text {
        id: labelItem
        // This keeps the TEXT vertically centered relative to the Row's height
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.textOffset
        
        text: root.text
        color: root.textColor
        font.family: root.textFont
        font.pixelSize: root.textSize
        font.bold: root.textBold
        visible: text !== ""
        
        width: root.textWidth > 0 ? root.textWidth : implicitWidth
        elide: root.elide
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
