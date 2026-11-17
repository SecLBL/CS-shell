pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// Label with a segmented choice, for a handful of [value, label] options
ConnectedRect {
    id: root

    property alias label: label.text
    property string subtext
    property var options: []
    property var current

    signal picked(value: var)

    Layout.fillWidth: true
    implicitHeight: row.implicitHeight + Tokens.padding.small * 2

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        anchors.leftMargin: Tokens.padding.largeIncreased
        spacing: Tokens.spacing.medium

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                id: label

                Layout.fillWidth: true
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtext
                text: root.subtext
                color: Colours.palette.m3outline
                font: Tokens.font.label.small
                elide: Text.ElideRight
            }
        }

        Segmented {
            options: root.options
            current: root.current
            onPicked: v => root.picked(v)
        }
    }
}
