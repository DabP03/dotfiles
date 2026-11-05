import QtQuick
import Quickshell
import Quickshell.Hyprland

import "root:/config/"

PopupWindow {
    id: popup

    // what to center under, and the window it lives in
    required property Item target
    required property var bar

    // how far the popup overlaps the bar's bottom edge
    property int overlap: 3

    // exposes the focus grab state (popup.visible is already a PopupWindow property)
    property alias grabActive: grab.active

    // children declared where you use the component land in here
    default property alias content: container.data

    // Lifecycle: 0 closed · 1 entering · 2 open · 3 leaving. The surface stays
    // mapped for its whole life, so the exit is ours to animate instead of the
    // compositor's fade-out on unmap.
    property int phase: 0
    readonly property bool live: phase > 0

    visible: popup.live
    // A popup that is not fully open takes no input, so a dying one can't be clicked.
    // Input follows the content while it arrives; a leaving popup takes no clicks.
    mask: Region { item: popup.phase === 3 ? noInput : container }

    // Animators take `to` only, so re-opening mid-exit reverses from wherever it
    // is instead of snapping to the start value.
    function open() {
        exitAnim.stop()
        popup.phase = 1
        grab.active = true
        container.freezeOrigin()
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

    implicitWidth: 300
    implicitHeight: 200
    color: "transparent"

    anchor.item: target
    anchor.rect.x: 0
    anchor.rect.y: bar.height - overlap - target.mapToItem(null, 0, 0).y
    anchor.rect.width: target.width
    anchor.rect.height: 0
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.None

    HyprlandFocusGrab {
        id: grab
        windows: [ popup ]
        active: false
        onCleared: popup.close()
    }

    Item {
        id: noInput
        width: 0
        height: 0
    }

    Item {
        id: container
        anchors.fill: parent
        opacity: 0

        // Frozen when the popup opens: the button can slide sideways as other bar
        // widgets resize, and a live origin binding would drag the pop-in along
        // with it while the surface itself stays put.
        property real originX: width / 2

        // Grow from the middle of the bar button that opened us. The popup is
        // placed with its horizontal centre on the anchor rect's centre, so the
        // button's offset from that centre is the origin. Measured inside the bar
        // window only - mapping into this popup's own surface is meaningless
        // because the two surfaces are separate scenes.
        function freezeOrigin() {
            originX = Math.max(0, Math.min(
                width,
                width / 2 + target.mapToItem(null, target.width / 2, 0).x
                - target.mapToItem(null, anchor.rect.x + anchor.rect.width / 2, 0).x
            ))
        }
        // Pop-in grows from the bar edge, like Hyprland's "popin" on a layer.
        // A transform exposes xScale/yScale only (no single `scale`), so both
        // axes carry the pop-in size.
        transform: Scale {
            id: popScale
            origin.x: container.originX
            origin.y: 0
            xScale: Motion.popinFrom
            yScale: Motion.popinFrom
        }
    }

    ParallelAnimation {
        id: enterAnim
        OpacityAnimator { target: container; to: 1; duration: Motion.fade }
        NumberAnimation {
            target: popScale
            property: "xScale"
            to: 1
            duration: Motion.popIn
            easing.type: Motion.arrive
        }
        NumberAnimation {
            target: popScale
            property: "yScale"
            to: 1
            duration: Motion.popIn
            easing.type: Motion.arrive
        }
        onFinished: popup.phase = 2
    }

    ParallelAnimation {
        id: exitAnim
        OpacityAnimator { target: container; to: 0; duration: Motion.popOut; easing.type: Motion.leave }
        NumberAnimation {
            target: popScale
            property: "xScale"
            to: 0.94
            duration: Motion.popOut
            easing.type: Motion.leave
        }
        NumberAnimation {
            target: popScale
            property: "yScale"
            to: 0.94
            duration: Motion.popOut
            easing.type: Motion.leave
        }
        onFinished: {
            popup.phase = 0
            grab.active = false
            // Qt.binding keeps the popinFrom binding alive; a bare assignment
            // would break it permanently.
            popScale.xScale = Qt.binding(() => Motion.popinFrom)
            popScale.yScale = Qt.binding(() => Motion.popinFrom)
        }
    }
}
