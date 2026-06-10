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

    title: qsTr("Equalizer")
    isSubPage: true

    property var eqState: ({
        enable: 1, gain: 0,
        HighPass: 0, HPfreq: 20, HPQ: 0.7,
        LowPass: 0, LPfreq: 20000, LPQ: 1.0,
        LSsec: 1, LSfreq: 80, LSq: 1.0, LSgain: 0,
        sec1: 1, freq1: 160, q1: 0.5, gain1: 0,
        sec2: 1, freq2: 397, q2: 0.5, gain2: 0,
        sec3: 1, freq3: 1250, q3: 0.5, gain3: 0,
        sec4: 1, freq4: 2500, q4: 0.5, gain4: 0,
        HSsec: 1, HSfreq: 8000, HSq: 1.0, HSgain: 0
    })

    function setEqParam(symbol: string, value: real): void {
        eqState = Object.assign({}, eqState, {
            [symbol]: value
        });
        eqParamProc.command = ["bash", "-c", 'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"', "0", "general-eq", symbol, String(value)];
        eqParamProc.running = false;
        eqParamProc.running = true;
    }

    Component.onCompleted: eqLoadProc.running = true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Process {
            id: eqLoadProc

            command: ["bash", "-c", 'jq -c ".[\\"general-eq\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
            stdout: SplitParser {
                onRead: line => {
                    try {
                        root.eqState = Object.assign({}, root.eqState, JSON.parse(line));
                    } catch (e) {}
                }
            }
        }

        Process {
            id: eqParamProc
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("fil4 parametric equalizer applied to the general output.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        // Master
        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Equalizer enabled")
            checked: root.eqState.enable > 0.5
            onToggled: root.setEqParam("enable", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            last: true
            label: qsTr("Master gain")
            from: -18
            to: 18
            unit: " dB"
            signed: true
            paramValue: root.eqState.gain
            onChanged: v => root.setEqParam("gain", Math.round(v * 10) / 10)
        }

        BandSection {
            header: qsTr("High-pass")
            enableSym: "HighPass"
            freqSym: "HPfreq"
            freqFrom: 5
            freqTo: 1250
            qSym: "HPQ"
            qFrom: 0
            qTo: 1.4
        }

        BandSection {
            header: qsTr("Low shelf")
            enableSym: "LSsec"
            freqSym: "LSfreq"
            freqFrom: 25
            freqTo: 400
            qSym: "LSq"
            qFrom: 0.0625
            qTo: 4
            gainSym: "LSgain"
        }

        BandSection {
            header: qsTr("Band 1")
            enableSym: "sec1"
            freqSym: "freq1"
            freqFrom: 20
            freqTo: 2000
            qSym: "q1"
            qFrom: 0.0625
            qTo: 4
            gainSym: "gain1"
        }

        BandSection {
            header: qsTr("Band 2")
            enableSym: "sec2"
            freqSym: "freq2"
            freqFrom: 40
            freqTo: 4000
            qSym: "q2"
            qFrom: 0.0625
            qTo: 4
            gainSym: "gain2"
        }

        BandSection {
            header: qsTr("Band 3")
            enableSym: "sec3"
            freqSym: "freq3"
            freqFrom: 100
            freqTo: 10000
            qSym: "q3"
            qFrom: 0.0625
            qTo: 4
            gainSym: "gain3"
        }

        BandSection {
            header: qsTr("Band 4")
            enableSym: "sec4"
            freqSym: "freq4"
            freqFrom: 200
            freqTo: 20000
            qSym: "q4"
            qFrom: 0.0625
            qTo: 4
            gainSym: "gain4"
        }

        BandSection {
            header: qsTr("High shelf")
            enableSym: "HSsec"
            freqSym: "HSfreq"
            freqFrom: 1000
            freqTo: 16000
            qSym: "HSq"
            qFrom: 0.0625
            qTo: 4
            gainSym: "HSgain"
        }

        BandSection {
            header: qsTr("Low-pass")
            enableSym: "LowPass"
            freqSym: "LPfreq"
            freqFrom: 500
            freqTo: 20000
            qSym: "LPQ"
            qFrom: 0
            qTo: 1.4
        }
    }

    component BandSection: ColumnLayout {
        id: band

        required property string header
        required property string enableSym
        required property string freqSym
        required property real freqFrom
        required property real freqTo
        required property string qSym
        required property real qFrom
        required property real qTo
        property string gainSym

        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            text: band.header
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            checked: root.eqState[band.enableSym] > 0.5
            onToggled: root.setEqParam(band.enableSym, checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Frequency")
            logScale: true
            from: band.freqFrom
            to: band.freqTo
            decimals: 0
            unit: " Hz"
            paramValue: root.eqState[band.freqSym]
            onChanged: v => root.setEqParam(band.freqSym, Math.round(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            last: !band.gainSym
            label: qsTr("Q")
            from: band.qFrom
            to: band.qTo
            decimals: 2
            paramValue: root.eqState[band.qSym]
            onChanged: v => root.setEqParam(band.qSym, Math.round(v * 100) / 100)
        }

        ParamSlider {
            Layout.fillWidth: true
            visible: !!band.gainSym
            last: true
            label: qsTr("Gain")
            from: -18
            to: 18
            unit: " dB"
            signed: true
            paramValue: band.gainSym ? root.eqState[band.gainSym] : 0
            onChanged: v => root.setEqParam(band.gainSym, Math.round(v * 10) / 10)
        }
    }
}
