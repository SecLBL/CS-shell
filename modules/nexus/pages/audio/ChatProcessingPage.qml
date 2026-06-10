pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Chat processing")
    isSubPage: true

    property bool nrEnabled: true

    function setNrEnabled(val: bool): void {
        nrEnabled = val;
        nrParamProc.command = ["bash", "-c", 'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-nr-bypass.sh" "$@"', "0", "chat-nr", val ? "1" : "0"];
        nrParamProc.running = false;
        nrParamProc.running = true;
    }

    Component.onCompleted: nrLoadProc.running = true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Process {
            id: nrLoadProc

            command: ["bash", "-c", 'jq -c "{chat_nr: (.chat_nr // 1)}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/routing.json" 2>/dev/null || echo "{\\"chat_nr\\":1}"']
            stdout: SplitParser {
                onRead: line => {
                    try {
                        root.nrEnabled = JSON.parse(line).chat_nr === 1;
                    } catch (e) {}
                }
            }
        }

        Process {
            id: nrParamProc
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("Processing chain applied to the chat output: noise reduction and compressor.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        SectionHeader {
            first: true
            text: qsTr("Noise reduction")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            last: true
            text: qsTr("Enabled")
            subtext: qsTr("RNNoise — neural network based noise suppression")
            checked: root.nrEnabled
            onToggled: root.setNrEnabled(checked)
        }

        CompressorControls {
            Layout.fillWidth: true
            plugin: "chat-comp"
        }
    }
}
