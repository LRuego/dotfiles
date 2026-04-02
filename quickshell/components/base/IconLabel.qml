// components/base/IconLabel.qml
import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.services.ui
import qs.core

Row {
    id: root

    // --- UNIFIED SIZE ---
    // `size` is the single scale knob. iconSize and textSize both
    // default to it, so callers only need to set `size` in most cases.
    // Override iconSize or textSize individually only when intentionally
    // mixing scales (e.g. a tiny superscript badge next to a larger icon).
    property int size: Theme.fontSize

    // --- ICON ---
    property string icon:       ""
    property color  iconColor:  labelColor
    property bool   colorize:   false
    property int    iconSize:   root.size
    // iconWidth: explicit override for fixed-width icon columns.
    // Leave at 0 to let the icon size itself naturally.
    property int    iconWidth:  0
    property string iconFont:   Theme.fontFamilyAlt
    property bool   iconBold:   labelBold

    // --- TEXT ---
    property string text:       ""
    property color  textColor:  labelColor
    property int    textSize:   root.size
    // textWidth: explicit override for fixed-width text columns (e.g. "100%").
    // Leave at 0 to let the text size itself naturally.
    property int    textWidth:  0
    property string textFont:   Theme.fontFamily
    property bool   textBold:   labelBold
    property int    elide:      Text.ElideNone

    // --- SHARED LABEL DEFAULTS ---
    property color  labelColor:   ThemeState.text
    property bool   labelBold:    false
    property int    labelSpacing: 4

    // --- SHOW/HIDE TEXT ---
    property bool showText: true

    spacing: labelSpacing

    readonly property bool isImageIcon: icon.includes("/") || icon.includes("://")
    readonly property bool isThemeIcon: icon !== "" && !isImageIcon && icon.length > 2

    // --- IMAGE / THEME ICON ---
    IconImage {
        id: imageIconItem

        source: isImageIcon ? root.icon : (isThemeIcon ? "image://icon/" + root.icon : "")

        implicitSize: root.iconWidth > 0 ? root.iconWidth : root.iconSize

        visible: (isImageIcon || isThemeIcon) && root.icon !== ""

        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: visible && root.colorize && root.iconColor.a > 0
        layer.effect: MultiEffect {
            colorization:     1.0
            colorizationColor: root.iconColor
        }
    }

    // --- FONT-BASED ICON (Nerd Font) ---
    Text {
        id: iconItem

        anchors.verticalCenter: parent.verticalCenter

        text:             (!isImageIcon && !isThemeIcon) ? root.icon : ""
        color:            root.iconColor
        font.family:      root.iconFont
        font.pixelSize:   root.iconSize
        font.bold:        root.iconBold
        visible:          text !== ""

        width:                root.iconWidth > 0 ? root.iconWidth : implicitWidth
        horizontalAlignment:  Text.AlignHCenter
        verticalAlignment:    Text.AlignVCenter
    }

    // --- TEXT LABEL ---
    Text {
        id: labelItem

        anchors.verticalCenter: parent.verticalCenter

        text:           root.text
        color:          root.textColor
        font.family:    root.textFont
        font.pixelSize: root.textSize
        font.bold:      root.textBold

        visible:  text !== ""
        clip:     true
        opacity:  root.showText ? 1 : 0

        width: (root.showText && text !== "")
            ? (root.textWidth > 0 ? root.textWidth : contentWidth)
            : 0

        elide:               root.elide
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
}
