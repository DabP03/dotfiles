import QtQuick
import Quickshell

import "../config/"
import "../services/"

Item {
    id: root
    required property ShellScreen screen

    // Quickshell already tracks the focused window, its monitor and appId.
    // Reading them from the Hyprland singleton avoids running two
    // `hyprctl activewindow` processes (one per screen) on every event.
    readonly property var toplevel: Hyprland.activeToplevel
    readonly property string className: {
        const t = root.toplevel;
        if (!t)
            return "";
        const appId = t.wayland ? t.wayland.appId : "";
        if (appId)
            return appId;
        // XWayland windows may not report an appId; fall back to the class
        // Hyprland last reported for the toplevel.
        const ipc = t.lastIpcObject;
        return ipc && ipc.class ? String(ipc.class) : "";
    }
    readonly property int monitor: root.toplevel && root.toplevel.monitor
        ? root.toplevel.monitor.id
        : -1

    implicitWidth: appName.implicitWidth + 20
    implicitHeight: parent.implicitHeight - 16

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        id: rect
        implicitWidth: root.implicitWidth * (appName.text != "")
        implicitHeight: root.implicitHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Motion.grow
            easing.type: Motion.arrive
        }
    }

        Behavior on color {
            ColorAnimation {
                duration: Motion.micro
                easing.type: Motion.arrive
            }
        }

        color: {
            let screenName = root.screen.name;
            if ((root.monitor === 0 && screenName.includes("DP")) || (root.monitor === 1 && screenName.includes("HDMI")) && (appName.text.length !== 0)) {
                return mouseArea.containsMouse ? Qt.lighter(Colors.red, 1.1) : Colors.red
            } else {
                return Colors.base
            }
        } 
        radius: 8

        Text {
            id: appName
            text: root.className !== "" ? root.formatClass(root.className) : ""
            visible: true
            font.pixelSize: Options.font.size
            font.family: Options.font.family
            font.bold: true
            anchors.centerIn: parent
            color: Colors.base
        }
    }

    function formatClass(className: string): string {
        let title = className
        switch (className) {
            case "zen":
            title = "Zen Browser"
            break;
            case "vesktop":
            title = "Vesktop"
            break;
            case "org.wezfurlong.wezterm":
            title = "Wezterm";
            break;
            case "org.kde.dolphin":
            title = "Dolphin";
            break;
            case "steam":
            title = "Steam";
            break;
            case "libreoffice-writer":
            title = "LibreOffice Writer";
            break;
            case "libreoffice-calc":
            title = "LibreOffice Calc";
            break;
            case "libreoffice-draw":
            title = "LibreOffice Draw";
            break;
            case "libreoffice-math":
            title = "LibreOffice Math";
            break;
            case "libreoffice-base":
            title = "LibreOffice Base";
            break;
            case "heroic":
            title = "Heroic Games Launcher";
            break;
            case "org.kde.gwenview":
            title = "Gwenview";
            break;
            case "vlc":
            title = "VLC";
            break;
            case "org.kde.kget":
            title = "KGet"
            break;
            case "affinity.exe":
            title = "Affinity"
            break;
            case "spotify":
            title = "Spotify"
            break;
            case "org.pwmt.zathura":
            title = "Zathura"
            break;
            case "org.strawberrymusicplayer.strawberry":
            title = "Strawberry"
            break
            case "org.prismlauncher.PrismLauncher":
            title = "Prism Launcher"
            break
            case "com.mitchellh.ghostty":
            title = "Ghostty"
            break
            case "undefined":
            title = ""
            break;
        }
        if (title.length > 30) {
            title = title.substring(27) + "...";
        }

        return title;
    }
}
