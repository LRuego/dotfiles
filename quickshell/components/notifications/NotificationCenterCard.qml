// components/notifications/NotificationCenterCard.qml
import QtQuick
import qs.core
import qs.services.ui
import qs.components.base

Rectangle {
    id: root

    // --- PROPERTIES ---
    property string appName: ""
    property string summary: ""
    property string body:    ""
    property string icon:    ""
    property string image:   ""
    property int    count:   1

    width:        parent?.width ?? 320
    height:       Math.max(56, cardLayout.implicitHeight + 24)
    radius:       Theme.cornerRadius
    color:        Theme.surface0
    border.color: ThemeState.border
    border.width: 1
    opacity:      0

    Component.onCompleted: addAnim.start()

    ListView.onAdd:    function() { addAnim.start() }
    ListView.onRemove: function() { removeAnim.start() }

    NumberAnimation {
        id:       addAnim
        target:   root
        property: "opacity"
        from:     0; to: 1
        duration: 300; easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: removeAnim
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation {
            target:   root
            property: "opacity"
            to:       0
            duration: 250; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target:   root
            property: "height"
            to:       0
            duration: 200; easing.type: Easing.OutQuad
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    Column {
        id:              cardLayout
        anchors.fill:    parent
        anchors.margins: 12
        spacing:         8

        Row {
            width:   parent.width
            spacing: 10

            // --- ICON + BADGE CONTAINER ---
            Item {
                width:                  28
                height:                 28
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id:                appIcon
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

                    fillMode: Image.PreserveAspectFit
                }

                // --- BADGE ---
                Rectangle {
                    visible:            root.count > 1
                    width:              16
                    height:             16
                    radius:             8
                    color:              Theme.urgent
                    anchors.top:        parent.top
                    anchors.left:       parent.left
                    anchors.topMargin:  -4
                    anchors.leftMargin: -4
                    z:                  10

                    Text {
                        anchors.centerIn: parent
                        text:             root.count > 99 ? "99+" : root.count
                        color:            Theme.base
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeTiny - 2
                        font.bold:        true
                    }
                }
            }

            // --- TEXT ---
            Column {
                width:                  parent.width - 28 - dismissButton.width - 20
                spacing:                2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text:           root.appName
                    color:          ThemeState.text
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold:      true
                    elide:          Text.ElideRight
                    width:          parent.width
                }

                Text {
                    text:           root.summary
                    width:          parent.width
                    color:          ThemeState.text
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide:          Text.ElideRight
                }

                Text {
                    text:             root.body
                    width:            parent.width
                    color:            Theme.subtext
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSmall
                    elide:            Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // --- DISMISS BUTTON ---
            Rectangle {
                id:                     dismissButton
                width:                  24
                height:                 24
                radius:                 12
                color:                  dismissArea.containsMouse ? ThemeState.border : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text:             "✕"
                    color:            Theme.subtext
                    font.pixelSize:   Theme.fontSizeSmall
                }

                MouseArea {
                    id:           dismissArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:    NotificationService.dismissHistory(root.appName)
                }
            }
        }

        // --- IMAGE PREVIEW ---
        Item {
            width:   parent.width
            height:  imagePreview.visible ? 80 : deletedLabel.visible ? 20 : 0
            visible: root.image !== ""

            Image {
                id:                imagePreview
                anchors.fill:      parent
                source:            root.image !== "" ? (root.image.startsWith("/") ? "file://" + root.image : root.image) : ""
                fillMode:          Image.PreserveAspectCrop
                autoTransform:     true
                sourceSize.width:  width * 2
                sourceSize.height: height * 2
                visible:           status !== Image.Error && root.image !== ""

                onStatusChanged: {
                    if (status === Image.Error) visible = false
                }

                Rectangle {
                    anchors.fill: parent
                    color:        "transparent"
                    border.color: ThemeState.border
                    border.width: 1
                    radius:       4
                }
            }

            // --- IMAGE DELETED PLACEHOLDER ---
            Text {
                id:             deletedLabel
                anchors.centerIn: parent
                visible:        imagePreview.status === Image.Error
                text:           "Image deleted"
                color:          Theme.subtext
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.italic:    true
            }
        }
    }
}
