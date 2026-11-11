pragma Singleton

import Quickshell
import QtQuick

// Clock strings shared by the bar and the dash.
//
// The bar only needs minutes, so the shared clock ticks once a minute. The
// dash shows seconds, and asks for the second-precision clock only while it is
// open (see DashComp), instead of formatting five strings every second all
// session long.
Singleton {
    id: root

    readonly property var plLocale: Qt.locale("pl_PL")

    // Set while the dash is open.
    property bool showSeconds: false

    readonly property string time: Qt.formatDateTime(secondClock.date, "hh:mm:ss")

    readonly property string timeI: Qt.formatDateTime(minuteClock.date, "󰥔 hh:mm")

    readonly property string date: Qt.formatDateTime(minuteClock.date, "dd.MM.yyyy")

    readonly property int maxFancyDateLen: 168

    readonly property string fancyDate: minuteClock.date.toLocaleDateString(plLocale, "dd MMMM yyyy")

    readonly property string year: Qt.formatDateTime(minuteClock.date, "yyyy")

    SystemClock {
        id: minuteClock
        precision: SystemClock.Minutes
    }

    SystemClock {
        id: secondClock
        precision: SystemClock.Seconds
        enabled: root.showSeconds
    }
}
