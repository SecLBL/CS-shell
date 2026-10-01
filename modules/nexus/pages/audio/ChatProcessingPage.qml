pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Chat processing")
    isSubPage: true
    compactFade: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("Processing chain applied to the chat output: noise reduction and compressor. Drag the node on the curve to set threshold and makeup, scroll over it to adjust the ratio.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        NoiseReductionControls {
            Layout.fillWidth: true
            first: true
            plugin: "chat-nr"
        }

        CompressorControls {
            Layout.fillWidth: true
            plugin: "chat-comp"
            scrollY: root.scrollY
        }
    }
}
