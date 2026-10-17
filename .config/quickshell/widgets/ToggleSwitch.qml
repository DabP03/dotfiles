import QtQuick

import "root:/config/"

// Simple on/off switch. It does not flip itself: bind `checked` to the real
// state and handle `clicked`, so the visual always matches the backend.
//
//   ToggleSwitch {
//       checked: NetworkService.wifiEnabled
//       enabled: NetworkService.wifiHardwareEnabled
//       onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
//   }

Rectangle {
    id: root

    property bool checked: false
    signal clicked()

    implicitWidth: 44
    implicitHeight: 24
    radius: height / 2
    color: checked ? Colors.blue : Colors.surface1
    opacity: enabled ? 1 : 0.4

    Behavior on color {
        ColorAnimation {
            duration: 120
            easing.type: Options.easingTypeOut
        }
    }

    Rectangle {
        id: knob
        width: root.height - 8
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 4 : 4
        color: root.checked ? Colors.base : Colors.text

        Behavior on x {
            NumberAnimation {
                duration: 120
                easing.type: Options.easingTypeOut
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
