// Icon.qml
import QtQuick

Text {
    property int fill: 1
    text: ""
    font.family: "Material Symbols Rounded"
    font.pixelSize: Options.font.size
    font.bold: true
    color: Colors.text
    renderType: Text.NativeRendering
    font.variableAxes: ({ "FILL": fill })
}
