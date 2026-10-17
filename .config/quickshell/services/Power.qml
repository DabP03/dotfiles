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
                return "electric_bold"
            } else if (percentage < .1) {
                return "battery_android_0"
            } else if (percentage < .25) {
                return "battery_android_1"
            } else if (percentage < .5) {
                return "battery_android_3"
            } else if (percentage < .75) {
                return "battery_android_5"
            } else {
                return "battery_android_full"
            }
        } else {
                return "power"
        }
    }
}
