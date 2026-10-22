import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland as Hypr
import "root:/config/"
import "root:/services/"

// Vim-style wallpaper picker: h/l move (wraps around), Enter apply, q (or Esc) close.
// The window only exists while open (LazyLoader), so it can never appear on its own.
Scope {
    id: root
    property bool shown: false

    // qs ipc call wallpaperPicker toggle|open|close
    IpcHandler {
        target: "wallpaperPicker"

        function toggle(): void {
            root.shown = !root.shown;
        }
        function open(): void {
            root.shown = true;
        }
        function close(): void {
            root.shown = false;
        }
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            id: win

            // open on the focused monitor
            screen: Quickshell.screens.find(s => s.name === Hypr.Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
            color: "transparent"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "wallpaper-picker"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            Component.onCompleted: Wallpaper.refresh()

            // awww query answers asynchronously; re-select once we know what's shown.
            Connections {
                target: Wallpaper
                function onCurrentChanged() {
                    const i = Wallpaper.indexOf(Wallpaper.current);
                    list.currentIndex = i;
                    list.positionViewAtIndex(i, PathView.Center);
                }
            }

            FocusScope {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    switch (event.key) {
                    case Qt.Key_H:
                        list.decrementCurrentIndex();
                        break;
                    case Qt.Key_L:
                        list.incrementCurrentIndex();
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        list.pick();
                        break;
                    case Qt.Key_Q:
                    case Qt.Key_Escape:
                        root.shown = false;
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                // dim backdrop, click outside the card to close
                Rectangle {
                    anchors.fill: parent
                    color: Qt.alpha(Colors.crust, 0.6)
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.shown = false
                }

                Rectangle {
                    id: card
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 80, 1400)
                    height: 320
                    radius: Options.radius
                    color: Colors.base
                    border.color: Colors.peach
                    border.width: Options.borderWidth

                    MouseArea {
                        anchors.fill: parent
                    } // swallow clicks on the card

                    // Wrap-around carousel: the selected wallpaper is always centered
                    // and the row is always full on both sides.
                    PathView {
                        id: list
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            topMargin: 24
                            leftMargin: Options.borderWidth
                            rightMargin: Options.borderWidth
                        }
                        height: 200
                        clip: true
                        interactive: false
                        model: Wallpaper.model

                        readonly property int itemW: 336
                        // how many thumbnails sit on the path (one spare on each side, off-screen)
                        readonly property int slots: Math.max(1, Math.min(count, Math.ceil(width / itemW) + 2))
                        readonly property real span: slots * itemW

                        pathItemCount: slots
                        highlightRangeMode: PathView.StrictlyEnforceRange
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightMoveDuration: 180

                        path: Path {
                            startX: list.width / 2 - list.span / 2
                            startY: list.height / 2
                            PathLine {
                                x: list.width / 2 + list.span / 2
                                y: list.height / 2
                            }
                        }

                        Component.onCompleted: {
                            const i = Wallpaper.indexOf(Wallpaper.current);
                            currentIndex = i;
                            positionViewAtIndex(i, PathView.Center);
                        }

                        function pick() {
                            if (count === 0 || currentIndex < 0)
                                return;
                            Wallpaper.apply(Wallpaper.model.get(currentIndex, "filePath"));
                            root.shown = false;
                        }

                        delegate: Item {
                            id: cell
                            required property int index
                            required property string filePath
                            required property url fileUrl

                            readonly property bool selected: PathView.isCurrentItem

                            width: list.itemW
                            height: list.height

                            Rectangle {
                                anchors.centerIn: parent
                                width: 320
                                height: 180
                                radius: Options.buttonRadius
                                color: Colors.surface0
                                border.width: cell.selected ? Options.borderWidth : 0
                                border.color: Colors.peach
                                scale: cell.selected ? 1.0 : 0.88
                                opacity: cell.selected ? 1.0 : 0.6

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Options.easingTypeOut
                                    }
                                }
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: Options.borderWidth
                                    source: cell.fileUrl
                                    sourceSize.width: 320
                                    sourceSize.height: 180
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                // marks the wallpaper that is currently displayed
                                Rectangle {
                                    visible: cell.filePath === Wallpaper.current
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: Colors.green
                                    border.color: Colors.base
                                    border.width: 2
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    list.currentIndex = cell.index;
                                    list.pick();
                                }
                            }
                        }
                    }

                    Text {
                        anchors {
                            top: list.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: Wallpaper.model.count === 0 ? "No images in ~/.wallpapers" : (list.currentIndex >= 0 ? Wallpaper.model.get(list.currentIndex, "fileName") : "")
                        color: Colors.text
                        font.family: Options.font.family
                        font.pixelSize: Options.font.size
                    }

                    Text {
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: 14
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: "h/l move  ·  enter apply  ·  q close"
                        color: Colors.overlay1
                        font.family: Options.font.family
                        font.pixelSize: Options.font.size - 3
                    }
                }
            }
        }
    }
}
