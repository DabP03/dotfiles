import QtQuick
import Quickshell.Widgets

// Rounded, cropped image.
//
// The image is decoded at the size it is drawn (or at an explicit
// decodeWidth/decodeHeight). Without this Qt decodes at the source resolution:
// a 1080p notification image is ~8 MB decoded, a 4K one ~33 MB, even when it
// is painted into a 36 px avatar.
//
// ClippingRectangle clips through one shader pass instead of the hidden mask
// layer + MultiEffect pipeline this used to use, which matters most when many
// avatars exist at once (notification lists).
ClippingRectangle {
    id: container

    required property string imgSource
    required property int radius

    // Optional decode size. 0 means "follow the drawn size".
    property int decodeWidth: 0
    property int decodeHeight: 0

    color: "transparent"
    radius: container.radius

    Image {
        anchors.fill: parent
        source: container.imgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: container.decodeWidth > 0
            ? container.decodeWidth
            : Math.max(1, Math.round(width))
        sourceSize.height: container.decodeHeight > 0
            ? container.decodeHeight
            : Math.max(1, Math.round(height))
    }
}
