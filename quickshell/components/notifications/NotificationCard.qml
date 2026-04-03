// components/notifications/NotificationCard.qml
import QtQuick
import qs.core
import qs.services.ui
import qs.components.base

Rectangle {
    id: root

    // --- PROPERTIES ---
    property string summary:    ""
    property string body:       ""
    property string icon:       ""
    property string image:      ""
    property string appName:    ""
    property int    notifId:    -1
    property int    count:      1
    property bool   hasDefault: false
    property int    urgency:    1

    width:        320
    height:       Math.max(64, mainLayout.implicitHeight + 32)
    radius:       Theme.cornerRadius
    color:        Theme.surface0
    border.color: root.urgency === 2 ? Theme.urgent : ThemeState.border
    border.width: 1
    opacity:      0
    x:            30

    Component.onCompleted: addAnim.start()

    ListView.onAdd:    function() { addAnim.start() }
    ListView.onRemove: function() { removeAnim.start() }

    ParallelAnimation {
        id: addAnim
        NumberAnimation { target: root; property: "opacity"; from: 0;  to: 1; duration: 400; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "x";       from: 30; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: removeAnim
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0;  duration: 300; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "x";       to: 30; duration: 300; easing.type: Easing.OutCubic }
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    // --- LAYOUT ---
    Column {
        id:              mainLayout
        anchors.fill:    parent
        anchors.margins: 16
        spacing:         12

        Row {
            id:      contentRow
            width:   parent.width
            spacing: 12

            // --- ICON + BADGE CONTAINER ---
            Item {
                width:                  32
                height:                 32
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id:                iconImage
                    anchors.fill:      parent
                    sourceSize.width:  width
                    sourceSize.height: height
                    smooth:            true
                    mipmap:            true

                    readonly property string finalFallback: Assets.notificationFallback
                    property string targetIcon: root.icon !== "" ? root.icon : finalFallback

                    source: {
                        if (targetIcon.startsWith("file://")) return targetIcon
                        if (targetIcon.startsWith("/"))       return "file://" + targetIcon
                        return "image://icon/" + targetIcon
                    }

                    onStatusChanged: {
                        if (status === Image.Error && targetIcon !== finalFallback)
                            targetIcon = finalFallback
                    }

                    visible:  root.icon !== ""
                    fillMode: Image.PreserveAspectFit
                }

                // --- BADGE (top-right of icon) ---
                Rectangle {
                    visible:             root.count > 1
                    width:               badgeText.implicitWidth + 6
                    height:              16
                    radius:              8
                    color:               Theme.urgent
                    anchors.top:         parent.top
                    anchors.right:       parent.right
                    anchors.topMargin:   -4
                    anchors.rightMargin: -6
                    z:                   10

                    Text {
                        id:               badgeText
                        anchors.centerIn: parent
                        text:             root.count > 99 ? "99+" : root.count
                        color:            Theme.base
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeTiny - 2
                        font.bold:        true
                    }
                }
            }

            Column {
                id:      textColumn
                width:   parent.width - 32 - 12
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text:           root.summary
                    width:          parent.width
                    color:          ThemeState.text
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold:      true
                    elide:          Text.ElideRight
                }

                Text {
                    text:             root.body
                    width:            parent.width
                    color:            Theme.subtext
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSmall
                    wrapMode:         Text.Wrap
                    maximumLineCount: root.image !== "" ? 2 : 4
                    elide:            Text.ElideRight
                }
            }
        }

        Image {
            id:                previewImage
            width:             parent.width
            height:            120
            source:            root.image !== "" ? (root.image.startsWith("/") ? "file://" + root.image : root.image) : ""
            visible:           root.image !== ""
            fillMode:          Image.PreserveAspectCrop
            autoTransform:     true
            sourceSize.width:  width * 2
            sourceSize.height: height * 2

            Rectangle {
                anchors.fill: parent
                color:        "transparent"
                border.color: ThemeState.border
                border.width: 1
                radius:       4
            }
        }
    }

    MouseArea {
        anchors.fill:    parent
        hoverEnabled:    true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape:     root.hasDefault ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton && root.hasDefault)
                NotificationService.invokeDefault(root.notifId, root.appName)
            else
                NotificationService.dismiss(root.notifId)
        }
        onEntered: NotificationService.pauseTimer(root.appName)
        onExited:  NotificationService.resumeTimer(root.appName)
    }
}
