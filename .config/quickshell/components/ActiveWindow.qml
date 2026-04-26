import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io

import "root:/config/"
import "root:/services/"
import "root:/widgets/"

Item {
    id: root
    required property ShellScreen screen
    property var monitor: 0
    // Behavior on implicitWidth { NumberAnimation { duration: 100 } }

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
            duration: 200
            easing.type: Options.easingTypeOut
        }
    }

        Behavior on color {
            ColorAnimation {
                duration: 100 // Transition duration in milliseconds
                easing.type: Options.easingTypeOut
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
            text: "" 
            visible: true
            Behavior on opacity {
                ColorAnimation {
                    duration: 100 // Transition duration in milliseconds
                    easing.type: Options.easingTypeOut
                }
            }
            font.pixelSize: Options.font.size
            font.family: Options.font.family
            font.bold: true
            anchors.centerIn: parent
            color: Colors.base
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (!event.name.endsWith("v2"))
            getActiveClient.running = true;
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


    Process {
        id: getActiveClient
        running: true
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const out = JSON.parse(this.text);
                let title = out.class;
                root.monitor = out.monitor;
                if (out.title == undefined) {
                    appName.text = "";
                    return;
                }

                appName.text = formatClass(title);
            }
        }
    }
}
