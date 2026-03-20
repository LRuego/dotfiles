// components/notifications/NotificationPopup.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services/ui"

PanelWindow {
    id: root

    visible: NotificationService.popupList.count > 0

    WlrLayershell.layer:     WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"
    exclusiveZone:           0

    anchors {
        top:    true
        right:  true
        bottom: true
    }

    margins {
        top:   44
        right: 15
    }

    implicitWidth: 320
    color:         "transparent"

    mask: Region { item: notificationList.contentItem }

    ListView {
        id: notificationList
        anchors {
            top:   parent.top
            right: parent.right
            left:  parent.left
        }
        height: Math.min(contentHeight, parent.height)

        spacing:     10
        model:       NotificationService.popupList
        interactive: false
        clip:        false

        delegate: NotificationCard {
            width:      ListView.view.width
            summary:    model.summary
            body:       model.body
            icon:       model.icon
            image:      model.image
            appName:    model.appName
            notifId:    model.notifId
            count:      model.count
            hasDefault: model.hasDefault
            urgency:    model.urgency
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 300; easing.type: Easing.OutQuad }
        }
    }
}
