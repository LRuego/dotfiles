// components/notifications/UpdatesSection.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.services.ui
import qs.services.system
import qs.components.base

Column {
    id: root

    width:   parent?.width ?? 320
    spacing: 0

    component PackageRow: Item {
        id: pkgRow

        required property string pkgName
        required property string pkgCurrent
        required property string pkgNext
        required property bool   isCore

        height: 28

        Rectangle {
            anchors.fill: parent
            radius:       4
            color:        pkgArea.containsMouse
                          ? Qt.rgba(1, 1, 1, 0.04)
                          : "transparent"
            Behavior on color { ColorAnimation { duration: 80 } }
        }

        Row {
            anchors {
                left:           parent.left
                right:          parent.right
                verticalCenter: parent.verticalCenter
                leftMargin:     4
                rightMargin:    4
            }
            spacing: 6

            Rectangle {
                visible:                pkgRow.isCore
                width:                  6
                height:                 6
                radius:                 3
                color:                  Theme.urgent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text:                   pkgRow.pkgName
                font.family:            Theme.fontFamily
                font.pixelSize:         Theme.fontSizeSmall
                color:                  pkgArea.containsMouse
                                        ? Theme.primary
                                        : ThemeState.text
                anchors.verticalCenter: parent.verticalCenter
                width:                  parent.width
                                      - versionLabel.implicitWidth
                                      - (pkgRow.isCore ? 12 : 0)
                                      - 6
                elide:                  Text.ElideRight
                Behavior on color { ColorAnimation { duration: 80 } }
            }

            Text {
                id:                     versionLabel
                text:                   pkgRow.pkgCurrent + " → " + pkgRow.pkgNext
                font.family:            Theme.fontFamily
                font.pixelSize:         Theme.fontSizeTiny
                color:                  Theme.subtext
                anchors.verticalCenter: parent.verticalCenter
                opacity:                pkgArea.containsMouse ? 0.4 : 0.6
                Behavior on opacity { NumberAnimation { duration: 80 } }
            }
        }

        Rectangle {
            id:      copyToast
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
            width:   toastLabel.implicitWidth + 10
            height:  18
            radius:  4
            color:   Theme.surface2
            opacity: 0
            visible: opacity > 0

            Text {
                id:               toastLabel
                anchors.centerIn: parent
                text:             "Copied!"
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSizeTiny
                color:            Theme.subtext
            }

            SequentialAnimation {
                id: toastAnim
                NumberAnimation { target: copyToast; property: "opacity"; to: 1;  duration: 100 }
                PauseAnimation  { duration: 850 }
                NumberAnimation { target: copyToast; property: "opacity"; to: 0;  duration: 180 }
            }
        }

        MouseArea {
            id:           pkgArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked: {
                Quickshell.clipboardText = "paru -S " + pkgRow.pkgName
                toastAnim.restart()
            }
        }
    }

    // ── Header row ────────────────────────────────────────────────────────────

    Item {
        width:  parent.width
        height: 48

        Row {
            id: headerRow
            anchors {
                left:           parent.left
                right:          parent.right
                verticalCenter: parent.verticalCenter
                rightMargin:    4
            }
            spacing: 8

            IconImage {
                source:                 Assets.packageIcon
                implicitSize:           Theme.fontSizeIcon
                anchors.verticalCenter: parent.verticalCenter
                layer.enabled:          true
                layer.effect: MultiEffect {
                    colorization:      1.0
                    colorizationColor: UpdateService.totalCount > 0
                                       ? Theme.primary
                                       : Theme.subtext
                }
            }

            Column {
                spacing:                2
                anchors.verticalCenter: parent.verticalCenter
                width:                  parent.width
                                      - Theme.fontSizeIcon
                                      - refreshBtn.width
                                      - chevronBtn.width
                                      - 32

                Text {
                    text:           UpdateService.checking
                                    ? "Checking…"
                                    : UpdateService.totalCount > 0
                                      ? UpdateService.totalCount + " updates pending"
                                      : "System up to date"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold:      true
                    color:          UpdateService.totalCount > 0
                                    ? ThemeState.text
                                    : Theme.subtext
                    elide:          Text.ElideRight
                    width:          parent.width
                }

                Text {
                    visible:        !UpdateService.checking && UpdateService.totalCount > 0
                    text:           UpdateService.extraUpdates.length + " official  ·  "
                                  + UpdateService.aurUpdates.length + " AUR"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    color:          Theme.subtext
                    elide:          Text.ElideRight
                    width:          parent.width
                }
            }

            Item {
                id:                     refreshBtn
                width:                  28
                height:                 28
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    anchors.centerIn: parent
                    source:           Assets.reload
                    implicitSize:     Theme.fontSizeSmall
                    layer.enabled:    true
                    layer.effect: MultiEffect {
                        colorization:      1.0
                        colorizationColor: refreshArea.containsMouse
                                           ? Theme.primary
                                           : Theme.subtext
                    }
                }

                MouseArea {
                    id:           refreshArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:    UpdateService.refresh()
                }
            }

            Item {
                id:                     chevronBtn
                width:                  28
                height:                 28
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    anchors.centerIn: parent
                    source:           Assets.caretDown
                    implicitSize:     Theme.fontSizeSmall
                    layer.enabled:    true
                    layer.effect: MultiEffect {
                        colorization:      1.0
                        colorizationColor: chevronArea.containsMouse
                                           ? ThemeState.text
                                           : Theme.subtext
                    }
                }

                MouseArea {
                    id:           chevronArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:    UpdateService.panelCollapsed = !UpdateService.panelCollapsed
                }
            }
        }
    }

    // ── Expandable body ───────────────────────────────────────────────────────

    Item {
        width:  parent.width
        height: UpdateService.panelCollapsed ? 0 : Math.min(scrollArea.implicitHeight, 200) + footer.implicitHeight
        clip:   true

        Behavior on height {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Column {
            width: parent.width

            ScrollView {
                id:                          scrollArea
                width:                       parent.width
                height:                      Math.min(bodyCol.implicitHeight, 200)
                contentWidth:                width
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    id:            bodyCol
                    width:         parent.width
                    spacing:       10
                    topPadding:    8
                    bottomPadding: 8

                    // ── [Official] ────────────────────────────────────────────────

                    Column {
                        width:   parent.width
                        spacing: 2
                        visible: UpdateService.extraUpdates.length > 0

                        Row {
                            Rectangle {
                                width:        officialBadgeText.implicitWidth + 10
                                height:       18
                                radius:       4
                                color:        Qt.rgba(Theme.info.r, Theme.info.g, Theme.info.b, 0.15)
                                border.color: Qt.rgba(Theme.info.r, Theme.info.g, Theme.info.b, 0.35)
                                border.width: 1

                                Text {
                                    id:               officialBadgeText
                                    anchors.centerIn: parent
                                    text:             "[Official]"
                                    font.family:      Theme.fontFamily
                                    font.pixelSize:   Theme.fontSizeTiny
                                    font.bold:        true
                                    color:            Theme.info
                                }
                            }
                        }

                        Repeater {
                            model: UpdateService.extraUpdates.length
                            delegate: PackageRow {
                                required property int modelData
                                width:      bodyCol.width
                                pkgName:    UpdateService.extraUpdates[modelData].name
                                pkgCurrent: UpdateService.extraUpdates[modelData].current
                                pkgNext:    UpdateService.extraUpdates[modelData].next
                                isCore:     UpdateService.extraUpdates[modelData].isCore
                            }
                        }
                    }

                    // ── [AUR] ─────────────────────────────────────────────────────

                    Column {
                        width:   parent.width
                        spacing: 2
                        visible: UpdateService.aurUpdates.length > 0

                        Row {
                            Rectangle {
                                width:        aurBadgeText.implicitWidth + 10
                                height:       18
                                radius:       4
                                color:        Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.15)
                                border.color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.35)
                                border.width: 1

                                Text {
                                    id:               aurBadgeText
                                    anchors.centerIn: parent
                                    text:             "[AUR]"
                                    font.family:      Theme.fontFamily
                                    font.pixelSize:   Theme.fontSizeTiny
                                    font.bold:        true
                                    color:            Theme.warning
                                }
                            }
                        }

                        Repeater {
                            model: UpdateService.aurUpdates.length
                            delegate: PackageRow {
                                required property int modelData
                                width:      bodyCol.width
                                pkgName:    UpdateService.aurUpdates[modelData].name
                                pkgCurrent: UpdateService.aurUpdates[modelData].current
                                pkgNext:    UpdateService.aurUpdates[modelData].next
                                isCore:     false
                            }
                        }
                    }

                    // ── Empty / checking states ───────────────────────────────────

                    Text {
                        width:               parent.width
                        visible:             UpdateService.totalCount === 0 && !UpdateService.checking
                        text:                "Everything is up to date"
                        color:               Theme.subtext
                        font.family:         Theme.fontFamily
                        font.pixelSize:      Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width:               parent.width
                        visible:             UpdateService.checking && UpdateService.totalCount === 0
                        text:                "Checking for updates…"
                        color:               Theme.subtext
                        font.family:         Theme.fontFamily
                        font.pixelSize:      Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Column {
                id:            footer
                width:         parent.width
                spacing:       8
                topPadding:    8
                bottomPadding: 8

                Rectangle {
                    width:        parent.width
                    height:       warnRow.implicitHeight + 14
                    radius:       Theme.cornerRadius
                    color:        Qt.rgba(Theme.urgent.r, Theme.urgent.g, Theme.urgent.b, 0.10)
                    border.color: Qt.rgba(Theme.urgent.r, Theme.urgent.g, Theme.urgent.b, 0.28)
                    border.width: 1
                    visible:      UpdateService.totalCount > 0

                    Row {
                        id:    warnRow
                        x:     10
                        y:     7
                        width: parent.width - 20

                        Text {
                            width:          parent.width
                            text:           "Partial upgrades can break Arch. When in doubt, run paru -Syu for a full system upgrade."
                            color:          Qt.rgba(Theme.urgent.r, Theme.urgent.g, Theme.urgent.b, 0.85)
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            wrapMode:       Text.WordWrap
                            lineHeight:     1.3
                        }
                    }
                }

                Text {
                    width:               parent.width
                    visible:             UpdateService.lastChecked !== ""
                    text:                UpdateService.lastChecked !== ""
                                         ? "Last checked " + root._formatTime(UpdateService.lastChecked)
                                         : ""
                    color:               Theme.subtext
                    font.family:         Theme.fontFamily
                    font.pixelSize:      Theme.fontSizeTiny
                    horizontalAlignment: Text.AlignRight
                    opacity:             0.6
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    function _formatTime(iso) {
        try {
            return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
        } catch (e) { return "" }
    }
}
