// components/base/MenuSectionLabel.qml
import QtQuick
import qs.core
import qs.services.ui

// A section header ("My Devices", ...) — owns its own inset, same reasoning as MenuHeader.
Text {
    property int inset: 12

    width:          parent.width
    leftPadding:    inset
    topPadding:     8
    bottomPadding:  4
    color:          Theme.subtext
    font.family:    Theme.fontFamily
    font.pixelSize: Theme.fontSizeSmall
    font.bold:      true
}
