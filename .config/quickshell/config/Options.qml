pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property Font font: Font {}
    readonly property Margin margin: Margin {}
    // Notification chime settings, read by NotificationService.
    readonly property QtObject sound: QtObject {
        property bool enabled: true
        // A burst of notifications plays one chime, not one per message.
        readonly property int cooldown: 250
        readonly property string normal: "/usr/share/sounds/freedesktop/stereo/message.oga"
        readonly property string critical: "/usr/share/sounds/freedesktop/stereo/dialog-error.oga"
    }
    readonly property int wallpaperSwitchTime: 30 * 60 * 1000
    readonly property int borderWidth: 2
    readonly property int radius: 16
    readonly property int buttonRadius: 8
    property string defaultPlayer: "Spotify"
    readonly property var easingTypeIn: Easing.InCubic
    readonly property var easingTypeOut: Easing.OutCubic
    readonly property var easingTypeInOut: Easing.InOutCubic
    property real barRightBottomRadius: 16

    component Font: QtObject {
        readonly property string family: "BlexMono Nerd Font"
        readonly property string iconFamily: "Material Symbols Rounded"
        readonly property real size: 16
    }
    
    component Margin: QtObject {
        readonly property int outer: 14
        readonly property int inner: 8
    }
}
