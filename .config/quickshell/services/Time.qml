pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
  id: root
  readonly property var plLocale: Qt.locale("pl_PL")

  readonly property string time: {
      Qt.formatDateTime(clock.date, "hh:mm:ss")
  }

  readonly property string timeI: {
      Qt.formatDateTime(clock.date, "󰥔 hh:mm")
  }

  readonly property string date: {
      Qt.formatDateTime(clock.date, "dd.MM.yyyy")
  }

readonly property int maxFancyDateLen: 168

  // readonly property string fancyDate: {
  //     plLocale.formatDate(clock.date, "dd MMMM yyyy")
  // }
  
  readonly property string fancyDate: {
      clock.date.toLocaleDateString(plLocale, "dd MMMM yyyy")
  }

  readonly property string year: {
      Qt.formatDateTime(clock.date, "yyyy")
  }


  SystemClock {
      id: clock
      precision: SystemClock.Seconds
  }
}
