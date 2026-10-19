// components/base/MenuHeader.qml
import QtQuick
import qs.core
import qs.services.ui

Item {
    id: root

    // --- ICON ---
    property string icon:          ""
    property int    iconSize:      28
    property bool   colorize:      false
    property color  iconColor:     ThemeState.text
    property bool   iconClickable: false
    property bool   pulsing:       false // e.g. a "connecting..." indicator
    onPulsingChanged: if (!pulsing) headerIcon.opacity = 1.0
    signal iconClicked()
    // Glow radius and size factor for the icon; the slot stays iconSize, so a bigger icon overflows it.
    property int  iconGlow:  0
    property real iconScale: 1

    // --- TEXT ---
    property string title:         ""
    property color  titleColor:    ThemeState.accent
    property string subtitle:      ""
    property color  subtitleColor: Theme.subtext
    property bool   subtitleMarquee: false // scrolls a cut-off subtitle instead of ending it with …

    // --- ACTIONS ---
    // Buttons placed at the right edge, e.g. MenuHeaderButton.
    default property alias actions: actionRow.data

    // --- LAYOUT ---
    // Owns its own inset regardless of the parent Menu's `padded` — a header is never a full-bleed row.
    property int inset:        12
    property int topPadding:   12
    property int bottomPadding: 12

    width:  parent.width
    height: contentRow.implicitHeight + topPadding + bottomPadding

    Row {
        id:      contentRow
        x:       root.inset
        y:       root.topPadding
        width:   root.width - root.inset * 2 - (actionRow.width > 0 ? actionRow.width + spacing : 0)
        spacing: 10

        Item {
            id:             iconSlot
            visible:        root.icon !== ""
            implicitWidth:  headerIcon.implicitWidth / root.iconScale
            implicitHeight: headerIcon.implicitHeight / root.iconScale
            // Center against the row's height, not top-align, so it spans title-to-subtitle.
            anchors.verticalCenter: parent.verticalCenter

            IconLabel {
                id:         headerIcon
                anchors.centerIn: parent
                icon:       root.icon
                iconSize:   Math.round(root.iconSize * root.iconScale)
                glowRadius: root.iconGlow
                colorize:   root.colorize
                iconColor:  root.iconColor

                SequentialAnimation on opacity {
                    running: root.pulsing
                    loops:   Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }
            }

            MouseArea {
                visible:     root.iconClickable
                enabled:     root.iconClickable
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:   root.iconClicked()
            }
        }

        // Takes the rest of the row so long text cuts off with … instead of running past the edge.
        Column {
            width: contentRow.width - (iconSlot.visible ? iconSlot.width + contentRow.spacing : 0)

            Text {
                width:          parent.width
                text:           root.title
                color:          root.titleColor
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold:      true
                elide:          Text.ElideRight
            }

            Text {
                width:          parent.width
                visible:        root.subtitle !== "" && !root.subtitleMarquee
                text:           root.subtitle
                color:          root.subtitleColor
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide:          Text.ElideRight
            }

            MarqueeText {
                width:          parent.width
                visible:        root.subtitle !== "" && root.subtitleMarquee
                text:           root.subtitle
                color:          root.subtitleColor
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    Row {
        id:      actionRow
        anchors.right:          parent.right
        anchors.rightMargin:    root.inset - 4
        anchors.verticalCenter: contentRow.verticalCenter
        spacing: 2
    }
}
