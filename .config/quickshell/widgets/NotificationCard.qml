import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// One notification inside the dash panel.
// Click the card to run the notification's "default" action (if it has one),
// use the x to dismiss, and the buttons for its other actions.
Rectangle {
    id: root

    required property var notification // Notification

    // Emitted after the card is clicked (and its default action, if any, ran).
    signal activated()

    readonly property var n: notification
    readonly property bool alive: n !== null && n !== undefined
    readonly property bool critical: alive && n.urgency === NotificationUrgency.Critical
    readonly property bool hasImage: alive && n.image !== ""
    readonly property bool hasDefault: alive && NotificationService.hasDefaultAction(n)
    readonly property var buttons: NotificationService.visibleActions(n)

    // Name or path of the app icon; AppTile can only resolve theme icon names.
    readonly property string iconName: {
        if (!alive)
            return "";
        const i = n.appIcon;
        if (i !== "" && !i.startsWith("/") && !i.startsWith("file:"))
            return i;
        return n.desktopEntry;
    }

    component SmallButton: StyledButton {
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
        buttonColor: Colors.surface0
        buttonTextColor: Colors.subtext0
        fontFamily: Options.font.iconFamily
        fontSize: 14
    }

    implicitHeight: content.implicitHeight + 20
    radius: Options.radius
    color: Colors.base
    border.width: critical ? 1 : 0
    border.color: Colors.peach

    MouseArea {
        anchors.fill: parent
        cursorShape: root.hasDefault ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            NotificationService.invokeDefault(root.n);
            root.activated();
        }
    }

    RowLayout {
        id: content
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        spacing: 10

        // ── icon / image ──
        Item {
            Layout.alignment: Qt.Center
            implicitWidth: 36
            implicitHeight: 36

            RoundedImage {
                anchors.fill: parent
                visible: root.hasImage
                imgSource: root.alive ? root.n.image : ""
                radius: Options.radius / 2
            }

            AppTile {
                anchors.centerIn: parent
                visible: !root.hasImage
                name: root.alive ? root.n.appName : ""
                iconName: root.iconName
            }
        }

        // ── text ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                    text: root.alive ? root.n.summary : ""
                    color: Colors.text
                    font.family: Options.font.family
                    font.pixelSize: Options.font.size - 1
                    font.bold: true
                }

                SmallButton {
                    buttonText: "close"
                    onClick: () => NotificationService.dismiss(root.n)
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                text: root.alive ? root.n.appName : ""
                color: root.critical ? Colors.peach : Colors.subtext0
                font.family: Options.font.family
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 2
                visible: text !== ""
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: root.alive ? NotificationService.stripMarkup(root.n.body) : ""
                color: Colors.text
                font.family: Options.font.family
                font.pixelSize: Options.font.size - 2
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: root.buttons.length > 0
                spacing: 6

                Repeater {
                    model: root.buttons

                    StyledButton {
                        required property var modelData
                        width: textWidth + 20
                        height: 26
                        fontSize: 12
                        buttonText: modelData.text
                        buttonColor: Colors.lavender
                        buttonTextColor: Colors.base
                        onClick: () => modelData.invoke()
                    }
                }
            }
        }
    }
}
