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

    property var nrState: ({
        enabled: 1,
        attenuation: 100
    })

    property var pendingNrParams: ({})

    function setNrParam(symbol: string, value: real): void {
        nrState = Object.assign({}, nrState, {
            [symbol]: value
        });
        pendingNrParams[symbol] = value;
        if (!nrFlushTimer.running)
            nrFlushTimer.start();
    }

    Component.onCompleted: nrLoadProc.running = true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Process {
            id: nrLoadProc

            command: ["bash", "-c", 'jq -c ".[\\"chat-nr\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
            stdout: SplitParser {
                onRead: line => {
                    try {
                        root.nrState = Object.assign({}, root.nrState, JSON.parse(line));
                    } catch (e) {}
                }
            }
        }

        Process {
            id: nrParamProc
        }

        Timer {
            id: nrFlushTimer

            interval: 80
            onTriggered: {
                if (nrParamProc.running) {
                    restart();
                    return;
                }
                const entries = Object.entries(root.pendingNrParams);
                if (entries.length === 0)
                    return;
                root.pendingNrParams = {};
                let script = 'P="${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh"';
                for (const [sym, val] of entries)
                    script += '; bash "$P" chat-nr ' + sym + ' ' + String(val);
                nrParamProc.command = ["bash", "-c", script];
                nrParamProc.running = true;
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("Processing chain applied to the chat output: noise reduction and compressor. Drag the node on the curve to set threshold and makeup, scroll over it to adjust the ratio.")
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
            text: qsTr("Enabled")
            subtext: qsTr("DeepFilterNet — deep learning noise suppression")
            checked: root.nrState.enabled > 0.5
            onToggled: root.setNrParam("enabled", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            last: true
            label: qsTr("Attenuation limit")
            from: 0
            to: 100
            decimals: 0
            unit: " dB"
            enabled: root.nrState.enabled > 0.5
            opacity: enabled ? 1 : 0.4
            paramValue: root.nrState.attenuation
            onChanged: v => root.setNrParam("attenuation", Math.round(v))
        }

        CompressorControls {
            Layout.fillWidth: true
            plugin: "chat-comp"
        }
    }
}
