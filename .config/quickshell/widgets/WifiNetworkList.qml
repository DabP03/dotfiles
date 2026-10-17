import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Networking

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

// Wi-Fi network list for the network popup.
// Drives everything through NetworkService:
//   connect / disconnect / forget buttons, inline password prompt for
//   NetworkService.pendingNetwork, wrong-password hint, spinner while a
//   network is changing state, and NetworkService.lastError at the bottom.

Item {
    id: root

    // signalStrength is a real in 0.0–1.0
    function signalSymbol(strength) {
        if (strength > 0.8) return "signal_wifi_4_bar";
        if (strength > 0.6) return "network_wifi_3_bar";
        if (strength > 0.4) return "network_wifi_2_bar";
        if (strength > 0.2) return "network_wifi_1_bar";
        return "signal_wifi_statusbar_null";
    }

    // Height the list wants when nothing needs scrolling (rows + error line).
    // The 56 floor leaves room for the empty-state text.
    readonly property real contentHeight: Math.max(list.contentHeight, 56) + errorText.height

    // Small button sized to its label, built on your StyledButton.
    component RowButton: StyledButton {
        Layout.preferredWidth: textWidth + 24
        Layout.preferredHeight: 28
        fontSize: 12
    }

    ListView {
        id: list
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: errorText.top
        }
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 4000 // keep every row instantiated so contentHeight isn't an estimate
        model: NetworkService.wifiNetworks

        delegate: Rectangle {
            id: row
            required property var modelData

            readonly property bool isPending: NetworkService.pendingNetwork === modelData
            readonly property bool busy: modelData.stateChanging
            readonly property bool showPrompt: isPending && !busy
            readonly property bool supported: NetworkService.canConnect(modelData)
            readonly property bool secured: !NetworkService.isOpenSecurity(modelData.security)

            property bool showPassword: false
            property string localHint: ""

            readonly property string subtitle: {
                if (modelData.state === ConnectionState.Connecting) return "Connecting…";
                if (modelData.state === ConnectionState.Disconnecting) return "Disconnecting…";
                if (isPending) return NetworkService.passwordRejected ? "Wrong password" : "Password required";
                if (modelData.connected) return "Connected";
                if (!supported) return "Needs setup elsewhere";
                if (modelData.known) return "Saved";
                return NetworkService.securityLabel(modelData);
            }

            function submit() {
                // WPA3 (SAE) passwords aren't bound to the 8–63 rule, so only check PSK types.
                if (modelData.security !== WifiSecurityType.Sae
                        && !NetworkService.passwordLooksValid(field.text)) {
                    localHint = "Passwords are 8 to 63 characters.";
                    return;
                }
                localHint = "";
                NetworkService.submitPassword(field.text);
            }

            onShowPromptChanged: if (showPrompt) field.forceActiveFocus()
            onIsPendingChanged: {
                if (!isPending) {
                    field.text = "";
                    showPassword = false;
                    localHint = "";
                }
            }

            width: ListView.view.width
            height: content.implicitHeight + 16
            radius: Options.radius
            clip: true
            color: (hover.hovered || isPending) ? Colors.surface0 : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Options.easingTypeOut
                }
            }

            HoverHandler { id: hover }

            ColumnLayout {
                id: content
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 8
                }
                spacing: 8

                // ── main row ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Icon {
                        text: root.signalSymbol(NetworkService.signalOf(row.modelData))
                        font.family: Options.font.iconFamily
                        font.pixelSize: 22
                        color: row.modelData.connected ? Colors.blue : Colors.text
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: row.modelData.name
                            color: row.modelData.connected ? Colors.blue : Colors.text
                            font.family: Options.font.family
                            font.pixelSize: Options.font.size
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: row.subtitle
                            color: (!row.supported || NetworkService.passwordRejected && row.isPending)
                                ? Colors.peach : Colors.subtext0
                            font.family: Options.font.family
                            font.pixelSize: 12
                        }
                    }

                    Icon {
                        visible: row.secured
                        text: "lock"
                        font.family: Options.font.iconFamily
                        font.pixelSize: 16
                        color: Colors.subtext0
                    }

                    Icon {
                        id: spinner
                        visible: row.busy
                        text: "progress_activity"
                        font.family: Options.font.iconFamily
                        font.pixelSize: 20
                        color: Colors.blue

                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 900
                            loops: Animation.Infinite
                            running: spinner.visible
                        }
                    }

                    RowButton {
                        visible: row.modelData.known && !row.busy && !row.isPending
                        buttonText: "Forget"
                        buttonColor: Colors.surface1
                        buttonTextColor: Colors.text
                        onClick: () => NetworkService.forget(row.modelData)
                    }

                    RowButton {
                        visible: row.modelData.connected && !row.busy
                        buttonText: "Disconnect"
                        buttonColor: Colors.surface1
                        buttonTextColor: Colors.text
                        onClick: () => NetworkService.disconnectFrom(row.modelData)
                    }

                    RowButton {
                        visible: !row.modelData.connected && row.supported && !row.busy && !row.isPending
                        buttonText: "Connect"
                        buttonColor: Colors.blue
                        buttonTextColor: Colors.base
                        onClick: () => NetworkService.connectTo(row.modelData)
                    }
                }

                // ── password prompt ──
                RowLayout {
                    visible: row.showPrompt
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: field
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        placeholderText: "Password"
                        placeholderTextColor: Colors.subtext0
                        echoMode: row.showPassword ? TextInput.Normal : TextInput.Password
                        selectByMouse: true
                        color: Colors.text
                        font.family: Options.font.family
                        font.pixelSize: Options.font.size
                        leftPadding: 10
                        rightPadding: 10

                        onAccepted: row.submit()
                        onTextChanged: row.localHint = ""
                        Keys.onEscapePressed: NetworkService.cancelPassword()

                        background: Rectangle {
                            radius: Options.radius / 2
                            color: Colors.base
                            border.width: Options.borderWidth
                            border.color: NetworkService.passwordRejected || row.localHint !== "" ? Colors.peach
                                : field.activeFocus ? Colors.blue
                                : Colors.surface1
                        }
                    }

                    RowButton {
                        buttonText: row.showPassword ? "Hide" : "Show"
                        buttonColor: Colors.surface1
                        buttonTextColor: Colors.text
                        onClick: () => row.showPassword = !row.showPassword
                    }
                }

                Text {
                    visible: row.showPrompt && (NetworkService.passwordRejected || row.localHint !== "")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: row.localHint !== "" ? row.localHint
                        : "That password didn’t work. Check it and try again."
                    color: Colors.peach
                    font.family: Options.font.family
                    font.pixelSize: 12
                }

                RowLayout {
                    visible: row.showPrompt
                    Layout.fillWidth: true
                    spacing: 8

                    Item { Layout.fillWidth: true }

                    RowButton {
                        buttonText: "Cancel"
                        buttonColor: Colors.surface1
                        buttonTextColor: Colors.text
                        onClick: () => NetworkService.cancelPassword()
                    }

                    RowButton {
                        buttonText: "Connect"
                        buttonColor: Colors.blue
                        buttonTextColor: Colors.base
                        onClick: () => row.submit()
                    }
                }
            }
        }
    }

    // ── empty state ──
    Text {
        anchors.centerIn: list
        visible: list.count === 0
        color: Colors.subtext0
        font.family: Options.font.family
        font.pixelSize: Options.font.size
        text: !NetworkService.wifiDevice ? "No Wi-Fi adapter found"
            : !NetworkService.wifiEnabled ? "Wi-Fi is off"
            : NetworkService.scanning ? "Scanning…"
            : "No networks found"
    }

    // ── last error ──
    Text {
        id: errorText
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: visible ? implicitHeight + 8 : 0
        visible: NetworkService.lastError !== ""
        verticalAlignment: Text.AlignBottom
        wrapMode: Text.WordWrap
        text: NetworkService.lastError
        color: Colors.peach
        font.family: Options.font.family
        font.pixelSize: 12
    }
}
