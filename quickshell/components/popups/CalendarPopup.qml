// components/popups/CalendarPopup.qml
import QtQuick
import Quickshell
import qs.components.base
import qs.services.system
import qs.services.ui
import qs.core

MenuPopup {
    id: root

    open:      false
    menuWidth: 280

    // --- STATE ---
    property int displayMonth: new Date().getMonth()
    property int displayYear:  new Date().getFullYear()

    readonly property int today:      new Date().getDate()
    readonly property int todayMonth: new Date().getMonth()
    readonly property int todayYear:  new Date().getFullYear()

    onVisibleChanged: {
        if (!visible) globalTooltip.hide(null)
        if (visible) {
            displayMonth = new Date().getMonth()
            displayYear  = new Date().getFullYear()
        }
    }

    // --- HELPERS ---
    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(month, year) {
        let d    = new Date(year, month, 1).getDay()
        let fdow = UserConfig.firstDayOfWeek
        return (d - fdow + 7) % 7
    }

    function prevMonth() {
        if (displayMonth === 0) { displayMonth = 11; displayYear-- }
        else displayMonth--
    }

    function nextMonth() {
        if (displayMonth === 11) { displayMonth = 0; displayYear++ }
        else displayMonth++
    }

    function dateStr(year, month, day) {
        return year + "-" +
               String(month + 1).padStart(2, "0") + "-" +
               String(day).padStart(2, "0")
    }

    readonly property var monthNames: [
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]

    readonly property var allDayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var dayNames: {
        let names = []
        for (let i = 0; i < 7; i++) {
            names.push(allDayNames[(i + UserConfig.firstDayOfWeek) % 7])
        }
        return names
    }

    // --- HEADER ---
    Item {
        width:  parent.width
        height: 28

        Row {
            anchors.fill: parent

            Rectangle {
                width:   28
                height:  28
                radius:  Theme.cornerRadius
                color:   prevArea.containsMouse ? ThemeState.hover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text:             "‹"
                    color:            ThemeState.text
                    font.pixelSize:   Theme.fontSizeLarge
                    font.bold:        true
                }

                MouseArea {
                    id:           prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.prevMonth()
                }
            }

            Item {
                width:  parent.width - 56
                height: 28

                Text {
                    anchors.centerIn: parent
                    text:             root.monthNames[root.displayMonth] + " " + root.displayYear
                    color:            ThemeState.text
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSmall
                    font.bold:        true
                }
            }

            Rectangle {
                width:   28
                height:  28
                radius:  Theme.cornerRadius
                color:   nextArea.containsMouse ? ThemeState.hover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text:             "›"
                    color:            ThemeState.text
                    font.pixelSize:   Theme.fontSizeLarge
                    font.bold:        true
                }

                MouseArea {
                    id:           nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.nextMonth()
                }
            }
        }
    }

    // --- DAY HEADERS ---
    Grid {
        width:   parent.width
        columns: 7

        Repeater {
            model: root.dayNames

            Item {
                width:  Math.floor(parent.width / 7)
                height: 24

                Text {
                    anchors.centerIn: parent
                    text:             modelData
                    color:            Theme.subtext
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeTiny
                    font.bold:        true
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

    // --- DAY GRID WRAPPER ---
    Item {
        width:  parent.width
        height: dayGrid.implicitHeight

        // Scroll to navigate months
        MouseArea {
            anchors.fill:            parent
            propagateComposedEvents: true
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) root.prevMonth()
                else root.nextMonth()
            }
        }

        Grid {
            id:      dayGrid
            width:   parent.width
            columns: 7

            property int totalDays:   root.daysInMonth(root.displayMonth, root.displayYear)
            property int firstOffset: root.firstDayOfMonth(root.displayMonth, root.displayYear)
            property int prevDays:    root.daysInMonth(
                                          root.displayMonth === 0 ? 11 : root.displayMonth - 1,
                                          root.displayMonth === 0 ? root.displayYear - 1 : root.displayYear
                                      )
            property int totalCells:  Math.ceil((firstOffset + totalDays) / 7) * 7

            Repeater {
                model: dayGrid.totalCells

                Item {
                    id:     dayCell
                    width:  Math.floor(parent.width / 7)
                    height: 32

                    property bool isPrevMonth: index < dayGrid.firstOffset
                    property bool isNextMonth: index >= dayGrid.firstOffset + dayGrid.totalDays
                    property int  dayNumber: {
                        if (isPrevMonth)  return dayGrid.prevDays - dayGrid.firstOffset + index + 1
                        if (isNextMonth)  return index - dayGrid.firstOffset - dayGrid.totalDays + 1
                        return index - dayGrid.firstOffset + 1
                    }
                    property bool isToday: !isPrevMonth && !isNextMonth
                                           && dayNumber === root.today
                                           && root.displayMonth === root.todayMonth
                                           && root.displayYear === root.todayYear

                    property string cellDateStr: !isPrevMonth && !isNextMonth
                        ? root.dateStr(root.displayYear, root.displayMonth, dayNumber)
                        : ""

                    property bool hasEvents: {
                        if (cellDateStr === "") return false
                        if (typeof CalendarService.hasEvents !== "function") return false
                        return CalendarService.hasEvents(cellDateStr)
                    }

                    // Hover + today highlight
                    Rectangle {
                        anchors.centerIn: parent
                        width:            parent.height
                        height:           parent.height
                        radius:           height / 2
                        color:            dayCell.isToday
                                              ? ThemeState.accent
                                              : cellArea.containsMouse
                                                  ? ThemeState.hover
                                                  : "transparent"
                    }

                    // Day number
                    Text {
                        anchors.centerIn: parent
                        text:             dayCell.dayNumber
                        color:            dayCell.isPrevMonth || dayCell.isNextMonth
                                              ? Theme.subtext
                                              : dayCell.isToday
                                                  ? Theme.base
                                                  : ThemeState.text
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeSmall
                        font.bold:        dayCell.isToday
                    }

                    // Holiday dot
                    Rectangle {
                        visible:                  dayCell.hasEvents
                        width:                    4
                        height:                   4
                        radius:                   2
                        color:                    dayCell.isToday ? Theme.base : ThemeState.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom:           parent.bottom
                        anchors.bottomMargin:     2
                    }

                    // Single MouseArea — hover highlight for all, tooltip for holiday cells only
                    MouseArea {
                        id:           cellArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            if (!dayCell.hasEvents) return
                            globalTooltip.hide(null)
                            if (typeof CalendarService.getEventsForDate !== "function") return
                            let events = CalendarService.getEventsForDate(dayCell.cellDateStr)
                            globalTooltip.show(cellArea, events.map(e => e.name).join("\n"))
                        }

                        onExited: {
                            if (dayCell.hasEvents) globalTooltip.hide(cellArea)
                        }
                    }
                }
            }
        }
    }
}
