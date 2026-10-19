// components/menus/VolumeMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.core
import qs.components.base
import qs.services.system
import qs.services.ui

// pavucontrol-style mixer: Playback / Recording / Output / Input tabs, a slider + level meter per row.
Menu {
    id: root

    menuWidth: 380
    padded:    false

    // "playback" | "recording" | "output" | "input"; kept between opens.
    property string tab: "playback"

    readonly property var tabs: [
        { key: "playback",  label: "Playback",  nodes: AudioService.playback,  empty: "Nothing playing",     pavuTab: 1 },
        { key: "recording", label: "Recording", nodes: AudioService.recording, empty: "Nothing recording",   pavuTab: 2 },
        { key: "output",    label: "Output",    nodes: AudioService.outputs,   empty: "No output devices",   pavuTab: 3 },
        { key: "input",     label: "Input",     nodes: AudioService.inputs,    empty: "No input devices",    pavuTab: 4 }
    ]
    readonly property var current: root.tabs.find(t => t.key === root.tab) ?? root.tabs[0]

    // Scrolling over the tab bar: down = next tab, up = previous; stops at the ends.
    function stepTab(forward) {
        let i = root.tabs.findIndex(t => t.key === root.tab) + (forward ? 1 : -1)
        if (i >= 0 && i < root.tabs.length) root.tab = root.tabs[i].key
    }

    // --- ROW HELPERS ---
    function _isInput(node) {
        let cls = AudioService.mediaClass(node)
        return cls.startsWith("Audio/Source") || cls === "Stream/Input/Audio"
    }

    function _muteIcon(node) {
        let muted = node?.audio?.muted ?? false
        if (root._isInput(node)) return muted ? Assets.microphoneMute : Assets.microphone
        return muted ? Assets.volumeMute : Assets.volumeHigh
    }

    // Apps use their own icon; devices (and apps without one) use a tinted glyph.
    function _appIcon(node) {
        let name = node?.isStream ? AudioService.appIconName(node) : ""
        return name ? Quickshell.iconPath(name, true) : ""
    }

    function _deviceIcon(node) {
        if (root._isInput(node)) return Assets.microphone
        let form = node?.properties?.["device.form-factor"] ?? ""
        return (form === "headset" || form === "headphone") ? Assets.headphones : Assets.speaker
    }

    // --- HEADER ---
    MenuHeader {
        icon:          AudioService.isMuted ? Assets.volumeMute : Assets.volumeHigh
        colorize:      true
        iconColor:     AudioService.isMuted ? Theme.urgent : ThemeState.accent
        iconClickable: true
        onIconClicked: AudioService.toggleMute()

        title:    "Sound"
        subtitleMarquee: true // long device names (e.g. "… Analog Surround 7.1") scroll instead of cutting off
        subtitle: AudioService.sink ? `${AudioService.volume}%  ·  ${AudioService.nodeTitle(AudioService.sink)}` : "No output"
    }

    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- TABS ---
    Row {
        width: parent.width

        Repeater {
            model: root.tabs

            delegate: Item {
                id:     tabItem
                width:  parent.width / root.tabs.length
                height: 34

                readonly property bool selected: root.tab === modelData.key

                Rectangle {
                    anchors.fill: parent
                    color:        tabArea.containsMouse && !tabItem.selected ? ThemeState.hover : "transparent"
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text:           modelData.label
                        color:          tabItem.selected ? ThemeState.accent : Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold:      tabItem.selected
                    }

                    Text {
                        visible:        modelData.nodes.length > 0
                        text:           modelData.nodes.length
                        color:          Theme.subtext
                        opacity:        0.7
                        font.family:    Theme.fontFamilyAlt
                        font.pixelSize: Theme.fontSizeTiny
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Selected tab underline.
                Rectangle {
                    visible: tabItem.selected
                    anchors.bottom:           parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:   parent.width - 24
                    height:  2
                    radius:  1
                    color:   ThemeState.accent
                }

                MouseArea {
                    id:           tabArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.tab = modelData.key
                    onWheel:      (wheel) => root.stepTab(wheel.angleDelta.y < 0)
                }
            }
        }
    }

    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- ROWS ---
    Text {
        visible:        root.current.nodes.length === 0
        width:          parent.width
        topPadding:     14
        bottomPadding:  14
        horizontalAlignment: Text.AlignHCenter
        text:           root.current.empty
        color:          Theme.subtext
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    MenuList {
        visible:    count > 0
        spacing:    0
        maxVisible: 5
        // Same node objects each update, so rows stay in place (no stale hover, sliders keep their drag).
        model:      ScriptModel { values: root.current.nodes }

        delegate: MenuItem {
            id:     row
            width:  ListView.view.width
            radius: 0 // full-bleed row
            implicitHeight: content.implicitHeight + 16

            readonly property var  node:     modelData
            readonly property bool isDevice: !(modelData?.isStream ?? true)
            readonly property bool muted:    modelData?.audio?.muted ?? false
            readonly property string appIcon: root._appIcon(modelData)

            // Devices: click makes it the default. Streams have nothing to pick.
            active:    isDevice && AudioService.isDefault(modelData)
            onClicked: (button) => { if (button === Qt.LeftButton && row.isDevice) AudioService.setDefault(row.node) }

            // Live level for the meter while the menu is open. Devices only: on app streams Quickshell 0.3.2
            // errors on a channel mismatch (stereo app into a 7.1 device) and the meter never moves.
            PwNodePeakMonitor {
                id:      peak
                node:    row.isDevice ? row.node : null
                enabled: root.visible && row.isDevice
            }

            Column {
                id:      content
                width:   parent.width
                spacing: 6

                RowLayout {
                    width:   parent.width
                    spacing: 10

                    IconLabel {
                        icon:      row.appIcon || root._deviceIcon(row.node)
                        iconSize:  20
                        colorize:  row.appIcon === ""
                        iconColor: row.active ? ThemeState.accent : Theme.subtext
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        // Scrolls when the name doesn't fit (long device names).
                        MarqueeText {
                            width:          parent.width
                            text:           AudioService.nodeTitle(row.node)
                            color:          row.active ? ThemeState.accent : Theme.text
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            readonly property string detail: row.isDevice
                                ? (row.active ? "Default" : "")
                                : AudioService.nodeDetail(row.node)
                            visible:        detail !== ""
                            width:          parent.width
                            text:           detail
                            color:          row.active ? Theme.success : Theme.subtext
                            font.family:    Theme.fontFamilyAlt
                            font.pixelSize: Theme.fontSizeTiny
                            elide:          Text.ElideRight
                        }
                    }

                    Text {
                        Layout.preferredWidth: 36
                        Layout.alignment:      Qt.AlignVCenter
                        horizontalAlignment:   Text.AlignRight
                        text:           Math.round((row.node?.audio?.volume ?? 0) * 100) + "%"
                        color:          row.muted ? Theme.urgent : Theme.subtext
                        font.family:    Theme.fontFamilyAlt
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MenuHeaderButton {
                        implicitWidth:  26
                        implicitHeight: 26
                        Layout.alignment: Qt.AlignVCenter
                        icon:       root._muteIcon(row.node)
                        iconSize:   16
                        iconColor:  row.muted ? Theme.urgent : Theme.subtext
                        hoverColor: row.muted ? Theme.urgent : ThemeState.accent
                        onClicked:  (button) => { if (row.node?.audio) row.node.audio.muted = !row.muted }
                    }
                }

                MenuSlider {
                    width:   parent.width
                    value:   row.node?.audio?.volume ?? 0
                    dimmed:  row.muted
                    level:   root.visible && row.isDevice ? peak.peak : -1
                    onMoved: (v) => { if (row.node?.audio) row.node.audio.volume = v }
                }
            }
        }
    }

    Rectangle {
        width:  parent.width
        height: 1
        color:  Theme.overlay
    }

    // --- FOOTER ---
    MenuFooter {
        icon:  Assets.settings
        label: "Open pavucontrol"
        onActivated: {
            Quickshell.execDetached(["pavucontrol", `--tab=${root.current.pavuTab}`])
            root.open = false
        }
    }
}
