// components/notifications/NotificationCenterCard.qml
import QtQuick
import qs.core
import qs.services.ui
import qs.components.base

Item {
    id: root

    // --- PROPERTIES ---
    property string appName: ""
    property string summary: ""
    property string body:    ""
    property string icon:    ""
    property string image:   ""
    property int    notifId:    -1
    property int    count:      1
    property bool   hasDefault: false
    property var    time:       0

    width:  parent?.width ?? 320
    height: Math.max(56, cardLayout.implicitHeight + 24)
    opacity: 0

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

    // --- HOVER TINT (full bleed — card spans panel edge-to-edge) ---
    Rectangle {
        anchors.fill: parent
        color:        cardArea.containsMouse ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Column {
        id:      cardLayout
        anchors {
            fill:         parent
            topMargin:    12
            bottomMargin: 12
            leftMargin:   16
            rightMargin:  16
        }
        spacing: 8

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

                // --- BADGE (top-right of icon) ---
                Rectangle {
                    visible:             root.count > 1
                    width:               Math.max(16, badgeText.implicitWidth + 6)
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

            // --- TEXT ---
            Column {
                width:                  parent.width - 28 - 10
                spacing:                2
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    width:   parent.width
                    spacing: 6

                    Text {
                        text:           root.appName
                        color:          ThemeState.text
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold:      true
                        elide:          Text.ElideRight
                        width:          parent.width - timeText.implicitWidth - 6
                    }

                    Text {
                        id:             timeText
                        text:           root.time > 0 ? _formatTime(root.time) : ""
                        color:          Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

            Text {
                id:               deletedLabel
                anchors.centerIn: parent
                visible:          imagePreview.status === Image.Error
                text:             "Image deleted"
                color:            Theme.subtext
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSizeSmall
                font.italic:      true
            }
        }
    }

    // --- INTERACTIONS ---
    MouseArea {
        id:              cardArea
        anchors.fill:    parent
        hoverEnabled:    true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape:     root.hasDefault ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton && root.hasDefault)
                NotificationService.invokeDefault(root.notifId, root.appName)
            else if (mouse.button === Qt.RightButton)
                NotificationService.dismissHistory(root.appName)
        }
    }

    // --- HELPERS ---
    function _formatTime(ts) {
        let diff = Math.floor((Date.now() - ts) / 1000)

        if (diff < 60)   return "just now"

        if (diff < 3600) {
            return Math.floor(diff / 60) + "m ago"
        }

        if (diff < 86400) {
            let h = Math.floor(diff / 3600)
            let m = Math.floor((diff % 3600) / 60)
            return m > 0 ? h + "h " + m + "m ago" : h + "h ago"
        }

        // plain "Xd ago" for days 1–3, compound units kick in after 3 days
        if (diff < 259200) {
            return Math.floor(diff / 86400) + "d ago"
        }

        if (diff < 2592000) { // up to 30 days
            let w = Math.floor(diff / 604800)
            let d = Math.floor((diff % 604800) / 86400)
            if (w > 0) return d > 0 ? w + "w " + d + "d ago" : w + "w ago"
            return Math.floor(diff / 86400) + "d ago"
        }

        // older than 30 days → absolute date
        let date     = new Date(ts)
        let months   = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let sameYear = date.getFullYear() === new Date().getFullYear()
        return months[date.getMonth()] + " " + date.getDate() + (sameYear ? "" : ", " + date.getFullYear())
    }
}
