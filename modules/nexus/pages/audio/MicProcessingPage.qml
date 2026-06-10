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

    title: qsTr("Mic processing")
    isSubPage: true

    property var gateState: ({
        enabled: 1,
        gt: 0.01, gz: 0.59566, gh: 0, ht: 0.25119, hz: 0.50119,
        gr: 0.000251, mk: 1.41254, at: 2.92, rt: 100, hold: 171
    })

    property bool nrEnabled: true

    function linToDb(v: real): real {
        return 20 * Math.log10(Math.max(v, 0.000001));
    }

    function dbToLin(db: real): real {
        return Math.pow(10, db / 20);
    }

    function setGateParam(symbol: string, value: real): void {
        gateState = Object.assign({}, gateState, {
            [symbol]: value
        });
        gateParamProc.command = ["bash", "-c", 'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"', "0", "mic-gate", symbol, String(value)];
        gateParamProc.running = false;
        gateParamProc.running = true;
    }

    function setNrEnabled(val: bool): void {
        nrEnabled = val;
        nrParamProc.command = ["bash", "-c", 'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-nr-bypass.sh" "$@"', "0", "mic-nr", val ? "1" : "0"];
        nrParamProc.running = false;
        nrParamProc.running = true;
    }

    Component.onCompleted: {
        gateLoadProc.running = true;
        nrLoadProc.running = true;
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Process {
            id: gateLoadProc

            command: ["bash", "-c", 'jq -c ".[\\"mic-gate\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
            stdout: SplitParser {
                onRead: line => {
                    try {
                        root.gateState = Object.assign({}, root.gateState, JSON.parse(line));
                    } catch (e) {}
                }
            }
        }

        Process {
            id: gateParamProc
        }

        Process {
            id: nrLoadProc

            command: ["bash", "-c", 'jq -c "{mic_nr: (.mic_nr // 1)}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/routing.json" 2>/dev/null || echo "{\\"mic_nr\\":1}"']
            stdout: SplitParser {
                onRead: line => {
                    try {
                        root.nrEnabled = JSON.parse(line).mic_nr === 1;
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
            text: qsTr("Processing chain applied to the microphone signal: gate, noise reduction and compressor.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        SectionHeader {
            first: true
            text: qsTr("Gate")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("LSP Gate Stereo — controls when the mic signal passes")
            checked: root.gateState.enabled > 0.5
            onToggled: root.setGateParam("enabled", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Threshold")
            from: -60
            to: 0
            unit: " dB"
            paramValue: root.linToDb(root.gateState.gt)
            onChanged: v => root.setGateParam("gt", root.dbToLin(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Zone")
            from: 0.001
            to: 1
            decimals: 3
            paramValue: root.gateState.gz
            onChanged: v => root.setGateParam("gz", Math.round(v * 1000) / 1000)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Attack")
            from: 0
            to: 2000
            unit: " ms"
            paramValue: root.gateState.at
            onChanged: v => root.setGateParam("at", Math.round(v * 10) / 10)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Hold")
            from: 0
            to: 1000
            unit: " ms"
            paramValue: root.gateState.hold
            onChanged: v => root.setGateParam("hold", Math.round(v * 10) / 10)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Release")
            from: 0
            to: 5000
            unit: " ms"
            paramValue: root.gateState.rt
            onChanged: v => root.setGateParam("rt", Math.round(v * 10) / 10)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Floor")
            from: -80
            to: 0
            unit: " dB"
            paramValue: root.linToDb(root.gateState.gr)
            onChanged: v => root.setGateParam("gr", root.dbToLin(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Makeup")
            from: -20
            to: 20
            unit: " dB"
            signed: true
            paramValue: root.linToDb(root.gateState.mk)
            onChanged: v => root.setGateParam("mk", root.dbToLin(v))
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Hysteresis")
            subtext: qsTr("Separate open and close thresholds")
            checked: root.gateState.gh > 0.5
            onToggled: root.setGateParam("gh", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Hysteresis threshold")
            from: -60
            to: 0
            unit: " dB"
            enabled: root.gateState.gh > 0.5
            opacity: enabled ? 1 : 0.4
            paramValue: root.linToDb(root.gateState.ht)
            onChanged: v => root.setGateParam("ht", root.dbToLin(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            last: true
            label: qsTr("Hysteresis zone")
            from: 0.001
            to: 1
            decimals: 3
            enabled: root.gateState.gh > 0.5
            opacity: enabled ? 1 : 0.4
            paramValue: root.gateState.hz
            onChanged: v => root.setGateParam("hz", Math.round(v * 1000) / 1000)
        }

        SectionHeader {
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
            plugin: "mic-comp"
        }
    }
}
