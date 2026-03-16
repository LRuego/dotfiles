// components/notifications/NotificationPopup.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 34
        right: 15
    }

    implicitWidth: 320
    implicitHeight: Math.max(1, notificationList.contentHeight)

    color: "transparent"
    
    // CRITICAL FIX: Only block clicks if we actually have notifications.
    // The mask now precisely follows the contentHeight of the list.
    mask: NotificationService.popupList.count > 0 ? null : emptyRegion
    
    Region { id: emptyRegion }

    ListView {
        id: notificationList
        anchors.fill: parent
        spacing: 10
        model: NotificationService.popupList
        interactive: false
        clip: false

        delegate: NotificationCard {
            summary: model.summary
            body: model.body
            icon: model.icon
            image: model.image // Added image mapping
            notifId: model.notifId
            closing: model.closing
            timeout: model.timeout
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 400; easing.type: Easing.OutQuad }
        }
    }
}
