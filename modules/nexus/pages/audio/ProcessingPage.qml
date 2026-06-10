pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Audio processing")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("Plugin chains running on the ChromaShell audio buses.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        NavRow {
            first: true
            icon: "equalizer"
            label: qsTr("Equalizer")
            status: qsTr("fil4 parametric EQ on the general output")
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "mic"
            label: qsTr("Mic processing")
            status: qsTr("Gate, noise reduction & compressor")
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            last: true
            icon: "headset_mic"
            label: qsTr("Chat processing")
            status: qsTr("Noise reduction & compressor")
            onClicked: root.nState.openSubPage(5)
        }
    }
}
