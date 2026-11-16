pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

// One audio track: on/off, recording volume, and whether it is taken after the ChromaShell chain
ConnectedRect {
    id: root

    required property var conf
    required property string track
    property alias label: label.text
    property bool canProcess

    readonly property bool on: conf[track]

    Layout.fillWidth: true
    implicitHeight: row.implicitHeight + Tokens.padding.small * 2

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        anchors.leftMargin: Tokens.padding.large
        anchors.rightMargin: Tokens.padding.large
        spacing: Tokens.spacing.medium

        StyledSwitch {
            checked: root.on
            onToggled: root.conf[root.track] = checked
        }

        StyledText {
            id: label

            Layout.preferredWidth: Tokens.font.body.small.pointSize * 7
            font: Tokens.font.body.small
            elide: Text.ElideRight
        }

        StyledSlider {
            Layout.fillWidth: true
            implicitHeight: Tokens.padding.medium * 2
            enabled: root.on
            value: root.conf[`${root.track}Volume`]
            onInteraction: v => root.conf[`${root.track}Volume`] = Math.round(v * 100) / 100
        }

        StyledText {
            Layout.preferredWidth: Tokens.font.body.small.pointSize * 3
            horizontalAlignment: Text.AlignRight
            text: Strings.percentOne(root.conf[`${root.track}Volume`])
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }

        IconTextButton {
            readonly property bool checked: root.conf[`${root.track}PostFilter`]

            visible: root.canProcess
            disabled: !root.on
            icon: checked ? "check_box" : "check_box_outline_blank"
            text: qsTr("Processed")
            type: IconTextButton.Text
            onClicked: root.conf[`${root.track}PostFilter`] = !checked
        }
    }
}
