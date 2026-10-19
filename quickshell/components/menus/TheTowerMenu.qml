// components/menus/TheTowerMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.components.base
import qs.services.input
import qs.services.system
import qs.services.ui

Menu {
    id: root

    // One fixed width (the old Tower menu's) for every page, so switching pages doesn't resize the menu.
    menuWidth: 450
    padded:    false

    // "main" | "layout" | "run" | "gem"; always reopens on main.
    property string page: "main"

    onOpenChanged: {
        if (!open) {
            globalTooltip.hide(null)
            return
        }
        root.page = "main"
        TheTowerService.refresh()
    }

    // Load a script's log only while its page is showing.
    Binding {
        target:   TheTowerService
        property: "logPart"
        value:    root.open && root.scriptPage ? root.page : ""
    }

    // counters: what each script counts (page stats rows and the main-menu row).
    readonly property var scripts: [
        // iconScale evens out how heavy each icon looks (the gem's outline reads bigger than the auto-restart arc).
        { key: "run", name: "Auto-Run", part: TheTowerService.run, icon: Assets.towerAutoRestart, iconScale: 1.0,
          about: "Clicks retry when a run ends",
          counters: [{ name: "triggers", label: "Triggers" }] },
        { key: "gem", name: "Auto-Gem", part: TheTowerService.gem, icon: Assets.towerGem, iconScale: 0.9,
          about: "Taps Bob and Ad Claim gems",
          // Bob = the orbiting gem box (YOLO), Ad Claim = the static gem button.
          counters: [{ name: "gems", label: "Bob" }, { name: "rewards", label: "Ad Claim" }] }
    ]

    readonly property var apps: [
        { name: "Waydroid",     detail: "The Tower",                   icon: Assets.waydroid, address: TheTowerService.waydroidAddress },
        { name: "Project Rend", detail: "Grouped with Helium",         icon: Assets.rendApp,  address: TheTowerService.rendAddress },
        { name: "Helium",       detail: UserConfig.towerHeliumProfile, icon: Assets.helium,   address: TheTowerService.heliumAddress }
    ]

    readonly property bool waydroidOpen: TheTowerService.waydroidAddress !== ""
    readonly property bool scriptPage:   root.page === "run" || root.page === "gem"
    readonly property var  current:      root.scripts.find(s => s.key === root.page) ?? root.scripts[0]

    // `counter` is an entry of a script's `counters` ({ name, label }).
    function _count(p, scope, counter) {
        return p.counts?.[scope]?.[counter.name] ?? 0
    }

    // "Bob 2  |  Ad Claim 1" for one scope (today / lifetime).
    function _countsLine(s, scope) {
        return s.counters.map(c => `${c.label} ${root._count(s.part, scope, c)}`).join("  |  ")
    }

    // Every successful tap today, summed across all scripts' counters.
    function _todayTaps() {
        let total = 0
        for (let s of root.scripts)
            for (let c of s.counters) total += root._count(s.part, "today", c)
        return total
    }

    // Row detail: never repeats the badge.
    function _detail(s) {
        let p = s.part
        if (p.error) return p.error
        if (p.state === "busy") return p.detail || "Working" // includes a manual run while off
        if (p.enabled && p.state !== "idle") return p.detail || "Working"
        if (p.enabled) return `Today: ${root._countsLine(s, "today")}`
        if (!TheTowerService.daemonActive) return "Service stopped"
        let anyToday = s.counters.some(c => root._count(p, "today", c) > 0)
        return anyToday ? `Today: ${root._countsLine(s, "today")}` : s.about
    }

    function _badge(p) {
        if (InputService.shiftHeld) return { text: "›",       color: Theme.subtext }
        if (p.error)               return { text: "Error",   color: Theme.urgent }
        if (p.state === "waiting") return { text: "Waiting", color: Theme.warning }
        return { text: "", color: Theme.subtext }   // on/off is shown by the icon colour
    }

    // Subtitle is state only; the counts live in the stats row under the header.
    function _pageSubtitle(s) {
        let p = s.part
        if (p.error) return `Error: ${p.error}`
        if (p.state === "busy" || p.state === "waiting") return p.detail || "Working"
        if (!p.enabled) return "Inactive"
        let started = p.counts?.sessionStarted ? Qt.formatDateTime(new Date(p.counts.sessionStarted * 1000), "MMM d, h:mm AP") : "?"
        return `Started ${started}`
    }

    // Log tags into plain words.
    function _logText(text) {
        return text
            .replace(/^RUN_COMPLETE run time (\S+).*$/, "Triggered retry (run lasted $1)")
            .replace(/^GEM_TAPPED /, "Tapped ")
    }

    // One log table row: { time: "14:29:34", level: "INFO"|"WARN"|"ERROR"|"DEBUG"|"DRY", msg }.
    function _logRow(e) {
        let dry   = e.text.startsWith("[dry] ")
        let level = dry ? "DRY" : (e.level === "WARNING" ? "WARN" : e.level)
        return { time: e.time, level: level, msg: root._logText(dry ? e.text.slice(6) : e.text) }
    }

    // Table rows (DEBUG hidden) plus a { divider: "Oct 17" } row wherever the day changes; `stripe` alternates per real row.
    function _logRows(entries) {
        let rows = []
        let lastDate = null
        let n = 0
        for (let e of entries) {
            if (e.level === "DEBUG" && !TheTowerService.logDebug) continue   // shown only with the Debug toggle
            if (e.date && e.date !== lastDate) {
                rows.push({ divider: Qt.formatDate(new Date(`${e.date}T00:00:00`), "MMM d") })
                lastDate = e.date
            }
            let r = root._logRow(e)
            r.stripe = n++ % 2 === 1
            rows.push(r)
        }
        return rows
    }

    function _levelColor(level) {
        if (level === "ERROR") return Theme.urgent
        if (level === "WARN")  return Theme.warning
        if (level === "INFO")  return Theme.primary
        return Theme.subtext   // DEBUG, DRY
    }

    function _messageColor(level) {
        if (level === "ERROR") return Theme.urgent
        if (level === "WARN")  return Theme.warning
        if (level === "DRY")   return Theme.subtext
        return ThemeState.text
    }

    // Fixed table columns, sized to their widest possible value.
    readonly property int logTimeWidth:  Math.ceil(logTimeMetrics.width)
    readonly property int logLevelWidth: Math.ceil(logLevelMetrics.width)
    readonly property int logColGap:     10

    TextMetrics {
        id:             logTimeMetrics
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        text:           "00:00:00"
    }

    TextMetrics {
        id:             logLevelMetrics
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold:      true
        text:           "[ERROR]"
    }



    // ==========================================================
    // MAIN PAGE
    // ==========================================================
    Column {
        width:   parent.width
        visible: root.page === "main"

        MenuHeader {
            // Same as the bar emblem, but the rainbow one once today's Ad Claims hit the daily 60.
            readonly property bool active:    TheTowerService.scriptsEnabled || TheTowerService.launching
            readonly property bool adsMaxed:  root._count(TheTowerService.gem, "today", { name: "rewards" }) >= 60
            icon:      adsMaxed ? Assets.towerEmblemRainbow : Assets.towerEmblem
            colorize:  !adsMaxed
            iconColor: active ? ThemeState.accent : Theme.subtext
            iconGlow:  adsMaxed || active ? 10 : 0
            iconScale: adsMaxed ? 1.27 : 1 // the rainbow's canvas is taller for its spikes; this keeps the hexagon the same size
            iconClickable: true
            onIconClicked: TheTowerService.toggleService() // same as clicking the bar module
            pulsing:   TheTowerService.launching

            title:    "The Tower"
            subtitle: {
                if (TheTowerService.launching) return TheTowerService.launchStep + "..."
                if (!TheTowerService.daemonActive) return "Service stopped"
                let on = root.scripts.filter(s => s.part.enabled).length
                return `${on}/${root.scripts.length} on  ·  ${root._todayTaps()} taps today`
            }

            // Click: launch (Waydroid closed) or fix the layout. Shift-click / right-click: layout page.
            MenuHeaderButton {
                icon: InputService.shiftHeld ? Assets.settings : (root.waydroidOpen ? Assets.panelLeft : Assets.play)
                onClicked: (button) => {
                    if (button === Qt.RightButton || InputService.shiftHeld) root.page = "layout"
                    else TheTowerService.launchOrFix()
                }
            }
        }

        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.overlay
        }

        // --- SCRIPTS ---
        MenuSectionLabel {
            text: "Scripts"
        }

        Repeater {
            model: ScriptModel {
                // Matched by key so status updates refresh rows in place; recreated rows could pick up a stale hover.
                values:     root.scripts
                objectProp: "key"
            }

            delegate: MenuItem {
                id:     scriptItem
                radius: 0
                implicitHeight: 44

                readonly property var part:  modelData.part
                readonly property var badge: root._badge(part)

                // Left: toggle. Right / Shift: open its page.
                onClicked: (button) => {
                    if (button === Qt.RightButton || InputService.shiftHeld) root.page = modelData.key
                    else if (button === Qt.LeftButton) TheTowerService.togglePart(modelData.key)
                }

                RowLayout {
                    width:   parent.width
                    spacing: 10

                    IconLabel {
                        icon:      modelData.icon
                        iconSize:  Math.round(20 * modelData.iconScale)
                        iconWidth: 20
                        colorize:  true
                        // Like Tailscale's online/offline peers: only the icon shows the state.
                        iconColor: scriptItem.part.enabled ? Theme.primary : Theme.overlay
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text:           modelData.name
                            color:          ThemeState.text
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            width:          scriptItem.width - 120
                            elide:          Text.ElideRight
                            text:           root._detail(modelData)
                            color:          scriptItem.part.error ? Theme.urgent : Theme.subtext
                            font.family:    Theme.fontFamilyAlt
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text:             scriptItem.badge.text
                        color:            scriptItem.badge.color
                        font.family:      Theme.fontFamilyAlt
                        font.pixelSize:   Theme.fontSizeSmall
                    }
                }
            }
        }
    }

    // ==========================================================
    // LAYOUT PAGE
    // ==========================================================
    Column {
        width:   parent.width
        visible: root.page === "layout"

        MenuHeader {
            icon:          Assets.caretLeft
            iconSize:      20
            colorize:      true
            iconColor:     Theme.subtext
            iconClickable: true
            onIconClicked: root.page = "main"
            pulsing:       TheTowerService.launching

            title:    "Layout"
            subtitle: {
                if (TheTowerService.launching) return TheTowerService.launchStep + "..."
                let w = TheTowerService.client(TheTowerService.waydroidAddress)
                return w ? `Workspace ${w.workspace.name}` : "Waydroid closed"
            }

            MenuHeaderButton {
                icon: root.waydroidOpen ? Assets.panelLeft : Assets.play
                onClicked: (button) => {
                    if (button === Qt.LeftButton) TheTowerService.launchOrFix()
                }
            }
        }

        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.overlay
        }

        // --- APPS ---
        MenuSectionLabel {
            text: "Apps"
        }

        Repeater {
            // Keyed so updates refresh rows in place; recreated rows can pick up a stale hover.
            model: ScriptModel { values: root.apps; objectProp: "name" }

            delegate: MenuItem {
                id:     appItem
                radius: 0
                implicitHeight: 44

                readonly property var win: TheTowerService.client(modelData.address)

                inactive: !win
                // Running: jump to it. Closed: start it and fix the layout around it.
                onClicked: (button) => {
                    if (button !== Qt.LeftButton) return
                    if (win) HyprlandService.focusWindow(modelData.address)
                    else TheTowerService.fixLayout()
                }

                RowLayout {
                    width:   parent.width
                    spacing: 10

                    // App logos stay in full colour; MenuItem's `inactive` dims them when the app isn't running.
                    IconLabel {
                        icon:      modelData.icon
                        iconSize:  20
                        iconWidth: 20
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text:           modelData.name
                            color:          Theme.text
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text:           modelData.detail
                            color:          Theme.subtext
                            font.family:    Theme.fontFamilyAlt
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text:             appItem.win ? `Workspace ${appItem.win.workspace.name}` : "Not running"
                        color:            appItem.win ? Theme.success : Theme.subtext
                        font.family:      Theme.fontFamilyAlt
                        font.pixelSize:   Theme.fontSizeSmall
                    }
                }
            }
        }
    }

    // ==========================================================
    // SCRIPT PAGE (Auto-Run / Auto-Gem): laid out like the old Tower menu
    // ==========================================================
    Column {
        width:   parent.width
        visible: root.scriptPage

        // Icon click goes back to the main page.
        MenuHeader {
            icon:          root.current.icon
            iconSize:      Math.round(28 * root.current.iconScale)
            colorize:      true
            iconColor:     root.current.part.enabled ? ThemeState.accent : Theme.subtext
            iconClickable: true
            onIconClicked: root.page = "main"
            pulsing:       root.current.part.state === "busy"

            title:         root.current.name
            subtitle:      root._pageSubtitle(root.current)
            subtitleColor: root.current.part.error ? Theme.urgent : Theme.subtext

            // Run once now (even while off). Shift-click / right-click: dry run, detects and logs without tapping.
            MenuHeaderButton {
                icon: InputService.shiftHeld ? Assets.flask : Assets.play
                onClicked: (button) => TheTowerService.runOnce(root.page, button === Qt.RightButton || InputService.shiftHeld)
            }
        }

        // --- DIVIDER ---
        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.overlay
        }

        // --- STATS ROW (one line per counter: Today / All) ---
        // Full-bleed rows with alternating backgrounds, like the log table.
        Column {
            width: parent.width

            Repeater {
                model: root.current.counters

                delegate: Rectangle {
                    id:     statRow
                    width:  parent.width
                    height: statCells.implicitHeight + 8
                    color:  index % 2 === 1 ? Theme.mantle : "transparent"

                    readonly property var counter: modelData
                    readonly property bool labelled: root.current.counters.length > 1

                    Row {
                        id:                     statCells
                        x:                      12
                        width:                  parent.width - 24
                        anchors.verticalCenter: parent.verticalCenter

                        // Label column only when there's more than one counter (Auto-Gem).
                        Text {
                            visible:        statRow.labelled
                            width:          visible ? 70 : 0
                            text:           statRow.counter.label
                            color:          Theme.subtext
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Repeater {
                            model: [["Today", "today"], ["All", "lifetime"]]

                            delegate: Row {
                                width:   (statCells.width - (statRow.labelled ? 70 : 0)) / 2
                                spacing: 6

                                Text {
                                    text:           modelData[0]
                                    color:          Theme.subtext
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                }

                                Text {
                                    text:           root._count(root.current.part, modelData[1], statRow.counter)
                                    color:          Theme.text
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold:      true
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.overlay
        }

        // --- LOG TABLE ---
        TextMetrics {
            id:             logMetrics
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            text:           "X"
        }

        // Column headers, with the Debug toggle on the right of the same line.
        Item {
            width:  parent.width
            height: logHeaderRow.height

            Row {
                id:            logHeaderRow
                x:             12
                topPadding:    6
                bottomPadding: 4
                spacing:       root.logColGap

                Repeater {
                    model: [
                        { text: "Time",    width: root.logTimeWidth },
                        { text: "Level",   width: root.logLevelWidth },
                        { text: "Message", width: 0 }
                    ]
                    delegate: Text {
                        width:          modelData.width > 0 ? modelData.width : implicitWidth
                        text:           modelData.text
                        color:          Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold:      true
                    }
                }
            }

            // Debug toggle: switches the table (and "Open log") to the debug file, which includes DEBUG lines.
            Text {
                anchors.right:       parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: logHeaderRow.verticalCenter
                text:                "Debug"
                color:               TheTowerService.logDebug ? Theme.primary : (debugArea.containsMouse ? Theme.text : Theme.overlay)
                font.family:         Theme.fontFamily
                font.pixelSize:      Theme.fontSizeTiny
                font.bold:           true

                MouseArea {
                    id:           debugArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    TheTowerService.logDebug = !TheTowerService.logDebug
                }
            }
        }

        Text {
            visible:        logList.count === 0
            x:              12
            bottomPadding:  4
            text:           "No logs yet"
            color:          Theme.subtext
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        // Full-bleed rows with alternating backgrounds; cells keep the 12px inset.
        // Long messages are cut with … and shown in full in a tooltip on hover.
        ListView {
            id:      logList
            visible: count > 0
            width:   parent.width
            clip:    true
            spacing: 0
            model:   root._logRows(TheTowerService.logEntries)

            readonly property int rowHeight:  Math.ceil(logMetrics.height) + 6
            readonly property int maxVisible: 5
            height: Math.min(count, maxVisible) * rowHeight

            onCountChanged: if (count > 0) Qt.callLater(() => logList.positionViewAtEnd())
            onVisibleChanged: if (visible) Qt.callLater(() => logList.positionViewAtEnd())
            onMovementStarted: globalTooltip.hide(null)

            delegate: Rectangle {
                id:     logRow
                width:  logList.width
                height: logList.rowHeight
                color:  modelData.stripe === true ? Theme.mantle : "transparent"

                readonly property bool isDivider: modelData.divider !== undefined

                // --- DATE DIVIDER ---
                Row {
                    visible: logRow.isDivider
                    x:       12
                    width:   parent.width - 24
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id:             dividerText
                        text:           modelData.divider ?? ""
                        color:          Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold:      true
                    }

                    Rectangle {
                        width:  parent.width - dividerText.width - parent.spacing
                        height: 1
                        color:  Theme.overlay
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // --- LOG ROW ---
                Row {
                    visible: !logRow.isDivider
                    x:       12
                    width:   parent.width - 24
                    spacing: root.logColGap
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        width:          root.logTimeWidth
                        text:           modelData.time ?? ""
                        color:          Theme.subtext
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    Text {
                        width:          root.logLevelWidth
                        text:           modelData.level ? `[${modelData.level}]` : ""
                        color:          root._levelColor(modelData.level)
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold:      true
                    }

                    Text {
                        id:             messageText
                        width:          parent.width - x
                        elide:          Text.ElideRight
                        text:           modelData.msg ?? ""
                        color:          root._messageColor(modelData.level)
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall

                        MouseArea {
                            anchors.fill:    parent
                            hoverEnabled:    true
                            acceptedButtons: Qt.NoButton
                            onEntered: if (messageText.truncated) globalTooltip.show(messageText, messageText.text)
                            onExited:  globalTooltip.hide(messageText)
                        }
                    }
                }
            }
        }

        // --- DIVIDER ---
        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.overlay
        }

        // --- FOOTER ---
        MenuFooter {
            label: "Open log"
            onActivated: {
                TheTowerService.openLog(root.page)
                root.open = false
            }
        }
    }

    // Not a full-bleed row, so it needs its own bottom gap (script pages end on a footer instead).
    Item { width: parent.width; height: 8; visible: !root.scriptPage }
}
