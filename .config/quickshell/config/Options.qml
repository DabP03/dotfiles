pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property Font font: Font {}
    property Width width: Width {}
    readonly property Margin margin: Margin {}
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
        readonly property string iconFamily: "BlexMono Nerd Font"
        readonly property real size: 16
    }

    component Width: QtObject {
         property int audio
         property int network
         property int clock
         property int tray
         property int dash
         property int battery
         property int player
    }
    
    component Margin: QtObject {
        readonly property int outer: 14
        readonly property int inner: 8
    }
}
