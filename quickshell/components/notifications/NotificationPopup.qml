import QtQuick
import Quickshell
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    margins {
        top: 34
        right: 15
    }

    implicitWidth: 320
    implicitHeight: 800 

    color: "transparent"
    
    // CRITICAL FIX: To prevent the "Same Item" crash, the window must stay visible.
    // To prevent it from blocking mouse clicks when empty, we use a window mask.
    // If count > 0, mask is null (whole window blocks). 
    // If count == 0, mask is an empty Region (everything passes through).
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
            notifId: model.notifId
            closing: model.closing
            timeout: model.timeout
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 400; easing.type: Easing.OutQuad }
        }
    }
}
