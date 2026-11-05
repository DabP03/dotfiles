pragma Singleton

import Quickshell
import QtQuick

// Motion vocabulary for the bar. Durations are the Hyprland speeds
// (1000 / speed) capped at 240ms, because a bar popup that takes Hyprland's
// ~670ms to leave feels broken.
//
// Curves: Qt 6 exposes animation easing as QEasingCurve, which only takes an
// enum `type` - there is no bezierSpline, so each Hyprland curve is mapped to
// the closest built-in curve instead of being reproduced as a spline.
//   easeOutQuint / quick  -> Easing.OutExpo   (strong deceleration, arrives)
//   easeInOutCubic        -> Easing.InOutCubic
//   almostLinear          -> Easing.InQuad    (gentle acceleration, leaves)
//   linear                -> Easing.Linear
Singleton {
    id: root

    readonly property int arrive: Easing.OutExpo
    readonly property int leave: Easing.InQuad
    readonly property int inOut: Easing.InOutCubic
    readonly property int linear: Easing.Linear

    // Roles. Everything here is <= 240ms; only `spin` (a loop, not a transition) is longer.
    readonly property int micro: 100     // hover tint              global speed 10
    readonly property int state: 120     // state colour / knob     fade speed 3.03, capped
    readonly property int pop: 150       // small pops: badge, tile, chevron
    readonly property int fade: 200      // opacity fades           was 500ms
    readonly property int grow: 200      // width / height changes
    readonly property int slide: 208     // travelling indicators   workspaces speed 4.8
    readonly property int popIn: 240     // popup enter             windowsIn speed 4.1
    readonly property real popinFrom: 0.87   // hyprland "popin 87%"
    readonly property int popOut: 240    // popup leave             windowsOut speed 1.49, capped
    readonly property int spin: 900      // busy spinner, loops
}
