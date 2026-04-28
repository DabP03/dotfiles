pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
  id: root
  readonly property string time: {
      Qt.formatDateTime(clock.date, "󰥔 hh:mm")
  }

  readonly property string date: {
      Qt.formatDateTime(clock.date, "dd.MM")
  }

  readonly property string year: {
      Qt.formatDateTime(clock.date, "yyyy")
  }

  SystemClock {
      id: clock
      precision: SystemClock.Seconds
  }
}
