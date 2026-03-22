// components/menus/CalendarPopup.qml
import QtQuick
import Quickshell
import qs.components.base
import qs.services.system
import qs.services.ui
import qs.core

MenuPopup {
    id: root

    open:       false
    menuWidth:  280

    // --- STATE ---
    property int displayMonth: ClockService.date ? new Date().getMonth() : new Date().getMonth()
    property int displayYear:  new Date().getFullYear()

    readonly property int today:       new Date().getDate()
    readonly property int todayMonth:  new Date().getMonth()
    readonly property int todayYear:   new Date().getFullYear()

    // --- HELPERS ---
    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(month, year) {
        // 0=Sun, shift to Mon=0
        let d = new Date(year, month, 1).getDay()
        return (d + 6) % 7
    }

    function prevMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear--
        } else {
            displayMonth--
        }
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear++
        } else {
            displayMonth++
        }
    }

    readonly property var monthNames: [
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]

    readonly property var dayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // --- HEADER ---
    Item {
        width:  parent.width
        height: 28

        Row {
            anchors.fill: parent

            // Prev button
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

            // Month + Year
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

            // Next button
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
                width: Math.floor(parent.width / 7)
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

    // --- DAY GRID ---
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
                width: Math.floor(parent.width / 7)
                height: 32

                property int  cellIndex:  index
                property bool isPrevMonth: cellIndex < dayGrid.firstOffset
                property bool isNextMonth: cellIndex >= dayGrid.firstOffset + dayGrid.totalDays
                property int  dayNumber: {
                    if (isPrevMonth)  return dayGrid.prevDays - dayGrid.firstOffset + cellIndex + 1
                    if (isNextMonth)  return cellIndex - dayGrid.firstOffset - dayGrid.totalDays + 1
                    return cellIndex - dayGrid.firstOffset + 1
                }
                property bool isToday: !isPrevMonth && !isNextMonth
                                       && dayNumber === root.today
                                       && root.displayMonth === root.todayMonth
                                       && root.displayYear === root.todayYear

                Rectangle {
                    anchors.centerIn: parent
                    width:            26
                    height:           26
                    radius:           height / 2
                    color:            dayCell.isToday ? ThemeState.accent : "transparent"
                }

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
            }
        }
    }
}
