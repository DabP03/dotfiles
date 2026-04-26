pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    readonly property var state: UPower.displayDevice.state
    readonly property var profile: PowerProfiles.profile
    readonly property bool isLaptopBattery: UPower.displayDevice.isLaptopBattery
    readonly property var charging: state === UPowerDeviceState.Charging
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property real timeToEmpty: UPower.displayDevice.timeToEmpty
    readonly property real timeToFull: UPower.displayDevice.timeToFull
    readonly property string icon: {
        if (isLaptopBattery) {
            if (charging) {
                return " "
            } else if (percentage < .1) {
                return "  "
            } else if (percentage < .25) {
                return "  "
            } else if (percentage < .5) {
                return "  "
            } else if (percentage < .75) {
                return "  "
            } else {
                return "  "
            }
        } else {
                return "<span font=\"FontAwesome 5 Free Solid\"></span>"
        }
    }
}
