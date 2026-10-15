import QtQuick
import Quickshell
import Quickshell.Hyprland

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

    function toggle() { visible = !visible; grab.active = !grab.active }
    function open()   { visible = true; grab.active = true }
    function close()  { visible = false; grab.active = false }

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
        onCleared: {
            popup.visible = false
            grab.active = false
        }
    }

    

    Item {
        id: container
        anchors.fill: parent
    }
}
