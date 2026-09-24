// components/base/MenuFooter.qml
import QtQuick
import qs.core
import qs.services.ui

// Single trailing-action row (icon + label) — edge-to-edge hover, unlike MenuHeader's inset.
MenuItem {
    id: root

    property string icon:       ""
    property int    iconSize:   Theme.fontSizeLarge
    property string label:      ""
    property int    labelSize:  Theme.fontSizeSmall
    property color  labelColor: Theme.subtext

    signal activated()

    width:  parent.width
    // Always the last thing in a menu by convention — round the bottom only.
    radius:            0
    bottomLeftRadius:  Theme.cornerRadius
    bottomRightRadius: Theme.cornerRadius
    onClicked: (button) => {
        if (button === Qt.LeftButton) root.activated()
    }

    IconLabel {
        icon:      root.icon
        iconSize:  root.iconSize
        text:      root.label
        textSize:  root.labelSize
        textColor: root.labelColor
    }
}
