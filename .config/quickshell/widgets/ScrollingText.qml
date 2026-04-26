import QtQuick

Item {
    id: root

    // Exposed properties for customization
    property alias text: songNameLabel.text
    property alias font: songNameLabel.font
    property alias color: songNameLabel.color
    // property alias scrollDuration: scrollAnimation.scrollDuration
    // property alias dwellTime: scrollAnimation.dwellTime
    property alias running: scrollAnimation.running
    property alias paused: scrollAnimation.paused
    property alias textWidth: songNameLabel.implicitWidth

    // Default values
    implicitWidth: 300  // Default width; set via parent or explicit
    implicitHeight: songNameLabel.implicitHeight
    clip: true

    // Pause before starting scroll (exposed as dwellTime)
    property int dwellTime: 2000

    // Scroll duration (exposed)
    property int scrollDuration: 10 * songNameLabel.implicitWidth

    // Main scrolling animation
    SequentialAnimation {
        id: scrollAnimation
        running: songNameLabel.implicitWidth > root.implicitWidth  // Only run if text is wider than container
        // running: true
        loops: Animation.Infinite


        // Scroll left
        NumberAnimation {
            target: songNameRect
            property: "x"
            from: 0
            to: root.implicitWidth - songNameLabel.implicitWidth
            duration: root.scrollDuration
            easing.type: Easing.InOutQuad
        }

        // Pause at end
        PauseAnimation { duration: 1000 }

        // Scroll right
        NumberAnimation {
            target: songNameRect
            property: "x"
            from: root.implicitWidth - songNameLabel.implicitWidth
            to: 0
            duration: root.scrollDuration
            easing.type: Easing.InOutQuad
        }

        // Pause at start (dwell time)
        PauseAnimation { duration: root.dwellTime }
    }


    // Scrolling text label
    Rectangle {
        id: songNameRect
        implicitWidth: songNameLabel.implicitWidth
        implicitHeight: songNameLabel.implicitHeight
        color: "transparent"
        Text {
            id: songNameLabel
            anchors.verticalCenter: parent.verticalCenter
            text: "Sample Scrolling Text"
            font.pixelSize: 18
            color: "#ffffff"
            // elide: Text.ElideNone

            onTextChanged: {
                scrollAnimation.restart()
                scrollAnimation.stop()
                songNameLabel.x = 0  // Reset position to start
                animTimer.restart()
            }
        }
        Timer {
            id: animTimer
            interval: 3000
            running: false
            repeat: false

            onTriggered: scrollAnimation.restart()
        }
    }
}
