pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// Rows hidden behind a "Settings" expander row, collapsed by default.
// Closes the card group itself while collapsed (acts as the last row).
ColumnLayout {
    id: root

    default property alias content: body.data
    property bool expanded

    Layout.fillWidth: true
    spacing: Tokens.spacing.extraSmall / 2

    ConnectedRect {
        Layout.fillWidth: true
        implicitHeight: headerLayout.implicitHeight + headerLayout.anchors.margins * 2
        last: !root.expanded

        StateLayer {
            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            id: headerLayout

            anchors.fill: parent
            anchors.margins: Tokens.padding.medium
            anchors.leftMargin: Tokens.padding.largeIncreased
            anchors.rightMargin: Tokens.padding.largeIncreased
            spacing: Tokens.spacing.medium

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Settings")
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }

            MaterialIcon {
                text: root.expanded ? "expand_less" : "expand_more"
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.medium
            }
        }
    }

    ColumnLayout {
        id: body

        Layout.fillWidth: true
        visible: root.expanded
        spacing: root.spacing
    }
}
