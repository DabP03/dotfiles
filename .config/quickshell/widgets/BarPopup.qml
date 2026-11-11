import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../config/"

PopupWindow {
    id: popup

    // what to center under, and the window it lives in
    required property Item target
    required property var bar

    // how far the popup overlaps the bar's bottom edge. Quickshell places the
    // popup's top edge one pixel below the anchor rect, measured on your bar:
    // borderWidth + 1 lands the top edge on the top of the bar's peach stroke,
    // so the 2px strip below covers exactly that stroke and the popup's own
    // borders start at the bar's bottom edge with no gap.
    property int overlap: Options.borderWidth + 1

    // exposes the focus grab state (popup.visible is already a PopupWindow property)
    property alias grabActive: grab.active

    // children declared where you use the component land in here
    default property Component content

    readonly property Item contentItem: loader.item

    // Visible height of the content. Animate this freely: it never resizes the window.
    // Defaults to implicitHeight, so popups that don't care behave as before.
    property real bodyHeight: implicitHeight

    // 0 = tucked into the bar, 1 = fully shown
    property real progress: 0

    // Lifecycle: 0 closed · 1 entering · 2 open · 3 leaving. The surface stays
    // mapped for its whole life, so the exit is ours to animate instead of the
    // compositor's fade-out on unmap.
    property int phase: 0
    readonly property bool live: phase > 0

    visible: implicitWidth > 0 && implicitHeight > 0
    // Input follows the revealed part, so a growing popup can't be clicked in
    // the not-yet-showing area and a leaving one takes no clicks at all.
    mask: Region { item: (popup.phase === 1 || popup.phase === 2) ? container : noInput }

    implicitWidth: 300
    implicitHeight: 200
    color: "transparent"

    // How much of the body is revealed, measured from the popup's top edge,
    // which sits `overlap` px above the bar's bottom edge. 0 = tucked in the bar.
    // No alpha animation: a hfading popup let the wallpaper bleed through and
    // flattened base and mantle into the same grey.
    property real reveal: 0

    function open() {
        exitAnim.stop()
        popup.phase = 1
        grab.active = true
        enterAnim.restart()
    }

    function close() {
        if (popup.phase === 0 || popup.phase === 3)
        return;
        enterAnim.stop()
        popup.phase = 3
        exitAnim.restart()
    }

    function toggle() { popup.live ? popup.close() : popup.open() }

    anchor.item: target
    anchor.rect.x: 0
    anchor.rect.y: bar.height - overlap - target.mapToItem(null, 0, 0).y
    anchor.rect.width: 2 * Math.round(target.width / 2) 
    anchor.rect.height: 0
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.None

    HyprlandFocusGrab {
        id: grab
        windows: [ popup ]
        active: popup.phase === 1 || popup.phase === 2
        onCleared: popup.close()
    }

    Item {
        id: noInput
        width: 0
        height: 0
    }

    // The clip that grows the body out of the bar. It is the only thing that
    // changes size; the body inside keeps its final layout, so text, sliders and
    // lists never reflow mid-animation and implicitHeight stays stable.
    Item {
        id: container
        anchors.top: parent.top
        anchors.left: parent.left
        width: popup.implicitWidth
        // floor() so a sub-pixel height never paints a 1px row; exact at 1 so a
        // fractional bodyHeight keeps its bottom border.
        height: popup.progress >= 1 ? popup.bodyHeight
        : Math.floor(popup.bodyHeight * popup.progress)
        clip: true
        // (no `visible:` binding here)

        Item {
            id: body
            width: popup.implicitWidth
            height: popup.bodyHeight

            Loader {
                id: loader
                anchors.fill: parent
                active: popup.live          // phase 1..3; unloads once phase returns to 0
                sourceComponent: popup.content
            }
        }
    }

    Behavior on bodyHeight {
        enabled: popup.phase === 2
        NumberAnimation { duration: Motion.grow; easing.type: Motion.inOut }
    }

    SequentialAnimation {
        id: enterAnim
        NumberAnimation {
            target: popup; property: "progress"; to: 1
            duration: Motion.popIn; easing.type: Motion.arrive
        }
        onFinished: popup.phase = 2
    }

    SequentialAnimation {
        id: exitAnim
        NumberAnimation {
            target: popup; property: "progress"; to: 0
            duration: Motion.popOut; easing.type: Motion.leave
        }
        PauseAnimation { duration: 50 }
        ScriptAction {
            script: {
                popup.phase = 0
                grab.active = false
            }
        }
    }
}
