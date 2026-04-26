import QtQuick
import QtQuick.Effects

Rectangle {
    id: container
    color: "transparent"
    required property string imgSource
    required property int radius

    Image {
        id: image
        anchors.fill: parent
        source: imgSource // Replace with your image source
        fillMode: Image.PreserveAspectCrop  // Crop to fit without distortion
        visible: false  // Hide original; we'll mask it
    }

    // Mask: A rounded rectangle defining the visible shape
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: container.radius
        visible: false  // Not rendered directly
        layer.enabled: true  // Enable for use as mask
    }

    // Apply the mask via MultiEffect
    MultiEffect {
        anchors.fill: image
        source: image
        maskEnabled: true
        maskSource: mask
    }
}
