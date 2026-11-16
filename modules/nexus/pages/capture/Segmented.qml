pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

// Segmented choice between a few [value, label] options
StyledRect {
    id: root

    property var options: []
    property var current

    signal picked(value: var)

    implicitWidth: segments.implicitWidth + Tokens.padding.extraSmall * 2
    implicitHeight: segments.implicitHeight + Tokens.padding.extraSmall * 2
    radius: Tokens.rounding.full
    color: Colours.tPalette.m3surfaceContainerHighest

    RowLayout {
        id: segments

        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: root.options

            TextButton {
                required property var modelData
                readonly property bool selected: root.current === modelData[0]

                text: modelData[1]
                type: selected ? TextButton.Filled : TextButton.Text
                inactiveOnColour: selected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                onClicked: root.picked(modelData[0])
            }
        }
    }
}
