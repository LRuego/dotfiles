// components/notifications/NotificationCenter.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.services.ui
import qs.services.system
import qs.components.base
import qs.components.notifications

PanelWindow {
    id: root

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "notifications-center"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    anchors {
        top:    true
        right:  true
        bottom: true
    }

    margins {
        top:    39
        right:  20
        bottom: 20
    }

    implicitWidth: 360
    color:         "transparent"
    visible:       true

    signal dismissed()
    onDismissed: NotificationService.centerVisible = false

    Timer {
        id:       focusDelay
        interval: 50
        onTriggered: FocusService.registerMenu(root)
    }

    Component.onCompleted: {
        focusDelay.start()
        slideAnim.start()
        fadeAnim.start()
    }

    mask: Region { item: panel }

    // --- OPEN ANIMATIONS ---
    NumberAnimation {
        id:          slideAnim
        target:      panel
        property:    "x"
        from:        root.implicitWidth + 20
        to:          0
        duration:    350
        easing.type: Easing.OutQuart
    }

    NumberAnimation {
        id:          fadeAnim
        target:      panel
        property:    "opacity"
        from:        0
        to:          1
        duration:    250
        easing.type: Easing.OutCubic
    }

    // --- PANEL ---
    Rectangle {
        id:      panel
        anchors {
            top:    parent.top
            bottom: parent.bottom
        }
        x:            root.implicitWidth + 20
        width:        root.implicitWidth
        opacity:      0
        radius:       Theme.cornerRadius
        color:        Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.8)
        border.color: ThemeState.border
        border.width: 1

        // --- HEADER ---
        Row {
            id:      header
            anchors {
                top:        parent.top
                left:       parent.left
                right:      parent.right
                topMargin:  16
                leftMargin: 16
                rightMargin: 16
            }
            height: 24

            Row {
                width:   parent.width - clearButton.width
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text:                   "Notifications"
                    color:                  ThemeState.text
                    font.family:            Theme.fontFamily
                    font.pixelSize:         Theme.fontSize
                    font.bold:              true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    visible:                historyList.count > 0
                    width:                  Math.max(18, countText.implicitWidth + 8)
                    height:                 18
                    radius:                 9
                    color:                  Theme.urgent
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id:               countText
                        anchors.centerIn: parent
                        text:             historyList.count > 99 ? "99+" : historyList.count
                        color:            Theme.base
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeTiny
                        font.bold:        true
                    }
                }
            }

            Rectangle {
                id:     clearButton
                width:  72
                height: 24
                radius: Theme.cornerRadius
                color:  clearArea.containsMouse ? ThemeState.accent : ThemeState.border

                Text {
                    anchors.centerIn: parent
                    text:             "Clear all"
                    color:            ThemeState.text
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSmall
                }

                MouseArea {
                    id:           clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:    NotificationService.clearHistory()
                }
            }
        }

        // --- DIVIDER ---
        Rectangle {
            id:      topDivider
            anchors {
                top:        header.bottom
                left:       parent.left
                right:      parent.right
                topMargin:  12
                leftMargin: 16
                rightMargin: 16
            }
            height: 1
            color:  ThemeState.border
        }

        // --- UPDATES SECTION ---
        Item {
            id: updatesWrapper
            anchors {
                bottom:       parent.bottom
                left:         parent.left
                right:        parent.right
                leftMargin:   16
                rightMargin:  16
                bottomMargin: 16
            }
            height: updatesDivider.height + updatesDivider.anchors.topMargin + updatesSection.implicitHeight
        }

        Rectangle {
            id: updatesDivider
            anchors {
                top:         updatesWrapper.top
                left:        parent.left
                right:       parent.right
                leftMargin:  16
                rightMargin: 16
            }
            height: 1
            color:  ThemeState.border
        }

        UpdatesSection {
            id: updatesSection
            anchors {
                top:         updatesDivider.bottom
                left:        parent.left
                right:       parent.right
                leftMargin:  16
                rightMargin: 16
            }
        }

        // --- LIST ---
        Item {
            anchors {
                top:          topDivider.bottom
                bottom:       updatesWrapper.top
                left:         parent.left
                right:        parent.right
                topMargin:    12
                bottomMargin: 12
                leftMargin:   16
                rightMargin:  16
            }

            ListView {
                id:           historyList
                anchors.fill: parent
                model:        NotificationService.historyList
                spacing:      8
                clip:         true

                delegate: NotificationCenterCard {
                    width:   ListView.view.width
                    appName: model.appName
                    summary: model.summary
                    body:    model.body
                    icon:    model.icon
                    image:   model.image
                    count:   model.count
                }

                displaced: Transition {
                    NumberAnimation { properties: "y"; duration: 300; easing.type: Easing.OutQuad }
                }

                Text {
                    anchors.centerIn: parent
                    visible:          historyList.count === 0
                    text:             "No notifications"
                    color:            Theme.subtext
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSmall
                }
            }

            ScrollBar {
                anchors.top:       parent.top
                anchors.right:     parent.right
                anchors.bottom:    parent.bottom
                policy:            ScrollBar.AsNeeded
                orientation:       Qt.Vertical
                size:              historyList.visibleArea.heightRatio
                position:          historyList.visibleArea.yPosition
                onPositionChanged: historyList.contentY = position * historyList.contentHeight
            }
        }
    }
}
