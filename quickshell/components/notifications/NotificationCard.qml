// components/notifications/NotificationCard.qml
import QtQuick
import Quickshell.Widgets
import "../../core"
import "../../services/ui"
import "../base"

ClippingRectangle {
    id: root

    property string summary: ""
    property string body: ""
    property string icon: ""
    property string image: ""
    property int    notifId: -1
    property bool   closing: false
    property int    timeout: 5000

    width: 320
    height: Math.max(64, mainLayout.implicitHeight + 32)
    radius: Theme.cornerRadius
    color: Theme.surface0
    border.color: ThemeState.border
    border.width: 1

    // --- PROGRESS ANIMATION ---
    NumberAnimation {
        id: progressAnim
        target: progressBar
        property: "width"
        from: root.width
        to: 0
        duration: root.timeout
        running: root.timeout > 0 && !root.closing
        onFinished: {
            if (!root.closing) NotificationService.dismiss(root.notifId)
        }
    }

    // --- PROGRESS BAR ---
    Rectangle {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 3
        color: ThemeState.accent
        visible: root.timeout > 0
        z: 10
    }

    // --- ANIMATION STATE ---
    opacity: 0
    x: 50

    states: [
        State {
            name: "visible"
            when: !root.closing
            PropertyChanges { target: root; opacity: 1; x: 0 }
        },
        State {
            name: "hidden"
            when: root.closing
            PropertyChanges { target: root; opacity: 0; x: 50 }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation { properties: "opacity,x"; duration: 400; easing.type: Easing.OutCubic }
            onRunningChanged: {
                if (!running && root.closing)
                    NotificationService.finalizeRemoval(root.notifId)
            }
        }
    ]

    Column {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Row {
            id: contentRow
            width: parent.width
            spacing: 12

            Image {
                id: iconImage
                width: 32
                height: 32
                sourceSize.width: width
                sourceSize.height: height
                smooth: true
                mipmap: true

                readonly property string finalFallback: Assets.notificationFallback
                property string targetIcon: root.icon && root.icon !== "" ? root.icon : finalFallback

                source: {
                    if (targetIcon.startsWith("file://")) return targetIcon
                    if (targetIcon.startsWith("/")) return "file://" + targetIcon
                    return "image://icon/" + targetIcon
                }

                onStatusChanged: {
                    if (status === Image.Error && targetIcon !== finalFallback)
                        targetIcon = finalFallback
                }

                visible: true
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                id: textColumn
                width: parent.width - (iconImage.visible ? iconImage.width + 12 : 0)
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: root.summary
                    width: parent.width
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.body
                    width: parent.width
                    color: Theme.subtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    maximumLineCount: root.image !== "" ? 2 : 4
                    elide: Text.ElideRight
                }
            }
        }

        Image {
            id: previewImage
            width: parent.width
            height: 120
            source: root.image !== "" ? (root.image.startsWith("/") ? "file://" + root.image : root.image) : ""
            visible: root.image !== ""
            fillMode: Image.PreserveAspectCrop
            autoTransform: true
            sourceSize: undefined

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: ThemeState.border
                border.width: 1
                radius: 4
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: NotificationService.dismiss(root.notifId)

        onEntered: {
            if (progressAnim.running) progressAnim.pause()
        }
        onExited: {
            if (progressAnim.paused) progressAnim.resume()
        }
    }
}
