// MyCalendar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/config/"

Control {
    id: control
    width: 300
    height: 300  // Increased height to accommodate header

    property date selectedDate: new Date()  // Default to today
    property date today: {
        let d = new Date();
        d.setHours(0, 0, 0, 0);  // Normalize to midnight for comparison
        return d;
    }
    property alias month: grid.month
    property alias year: grid.year

    Component.onCompleted: {
        // Initialize to current month/year if desired
        let today = new Date()
        month = today.getMonth()  // 0-11
        year = today.getFullYear()
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Navigation header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            ToolButton {
                text: " "  // Previous month
                onClicked: {
                    if (control.month === 0) {
                        control.month = 11
                        control.year--
                    } else {
                        control.month--
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Colors.text
                font.bold: true
                text: grid.locale.standaloneMonthName(control.month) + " " + control.year
            }

            ToolButton {
                text: " "  // Next month
                onClicked: {
                    if (control.month === 11) {
                        control.month = 0
                        control.year++
                    } else {
                        control.month++
                    }
                }
            }
        }

        // Calendar grid (without week numbers)
        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            DayOfWeekRow {
                locale: grid.locale
                Layout.fillWidth: true
            }

            MonthGrid {
                id: grid
                month: Calendar.December  // Will be overridden by properties
                year: 2023  // Will be overridden
                locale: control.locale
                Layout.fillWidth: true
                Layout.fillHeight: true

                delegate: Item {
                    required property var model

                    Text {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: model.month === grid.month ? 1 : 0.5
                        text: model.day
                        font: control.font
                        color: control.palette.text
                    }

                    // Highlight for selected date
                    Rectangle {
                        anchors.fill: parent
                        color: Colors.overlay1
                        opacity: 0.3
                        visible: model.date.getTime() === control.selectedDate.getTime()
                    }

                    // Separate highlight for today's date (e.g., border or different color)
                    Rectangle {
                        anchors.fill: parent
                        border.color: Colors.peach  // Red border for today
                        radius: Options.radius
                        border.width: 2
                        color: "transparent"
                        visible: model.date.getFullYear() === control.today.getFullYear() &&
                                 model.date.getMonth() === control.today.getMonth() &&
                                 model.date.getDate() === control.today.getDate()
                    }
                }

                onClicked: (date) => {
                    control.selectedDate = date
                    console.log("Selected:", date.toLocaleDateString())
                }
            }
        }
    }
}
