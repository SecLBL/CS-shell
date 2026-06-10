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

    readonly property var bands: [
        {
            name: qsTr("High-pass"),
            kind: "hp",
            enableSym: "HighPass",
            freqSym: "HPfreq",
            freqFrom: 5,
            freqTo: 1250,
            qSym: "HPQ",
            qFrom: 0,
            qTo: 1.4,
            gainSym: ""
        },
        {
            name: qsTr("Low shelf"),
            kind: "lowshelf",
            enableSym: "LSsec",
            freqSym: "LSfreq",
            freqFrom: 25,
            freqTo: 400,
            qSym: "LSq",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "LSgain"
        },
        {
            name: qsTr("Band 1"),
            kind: "peak",
            enableSym: "sec1",
            freqSym: "freq1",
            freqFrom: 20,
            freqTo: 2000,
            qSym: "q1",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "gain1"
        },
        {
            name: qsTr("Band 2"),
            kind: "peak",
            enableSym: "sec2",
            freqSym: "freq2",
            freqFrom: 40,
            freqTo: 4000,
            qSym: "q2",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "gain2"
        },
        {
            name: qsTr("Band 3"),
            kind: "peak",
            enableSym: "sec3",
            freqSym: "freq3",
            freqFrom: 100,
            freqTo: 10000,
            qSym: "q3",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "gain3"
        },
        {
            name: qsTr("Band 4"),
            kind: "peak",
            enableSym: "sec4",
            freqSym: "freq4",
            freqFrom: 200,
            freqTo: 20000,
            qSym: "q4",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "gain4"
        },
        {
            name: qsTr("High shelf"),
            kind: "highshelf",
            enableSym: "HSsec",
            freqSym: "HSfreq",
            freqFrom: 1000,
            freqTo: 16000,
            qSym: "HSq",
            qFrom: 0.0625,
            qTo: 4,
            gainSym: "HSgain"
        },
        {
            name: qsTr("Low-pass"),
            kind: "lp",
            enableSym: "LowPass",
            freqSym: "LPfreq",
            freqFrom: 500,
            freqTo: 20000,
            qSym: "LPQ",
            qFrom: 0,
            qTo: 1.4,
            gainSym: ""
        }
    ]

    property int selectedBand: 2
    readonly property var currentBand: bands[selectedBand]

    property var pendingParams: ({})

    // All writes go through here: the state updates immediately (so the
    // graph and sliders react live) while the script calls are batched and
    // flushed sequentially. audio-param.sh does a jq read-modify-write on
    // audio.json, so concurrent invocations during fast dragging would
    // race each other.
    function queueEqParam(symbol: string, value: real): void {
        eqState = Object.assign({}, eqState, {
            [symbol]: value
        });
        pendingParams[symbol] = value;
        if (!flushTimer.running)
            flushTimer.start();
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

        Timer {
            id: flushTimer

            interval: 80
            onTriggered: {
                if (eqParamProc.running) {
                    restart();
                    return;
                }
                const entries = Object.entries(root.pendingParams);
                if (entries.length === 0)
                    return;
                root.pendingParams = {};
                let script = 'P="${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh"';
                for (const [sym, val] of entries)
                    script += '; bash "$P" general-eq ' + sym + ' ' + String(val);
                eqParamProc.command = ["bash", "-c", script];
                eqParamProc.running = true;
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: qsTr("fil4 parametric equalizer applied to the general output. Drag a node to set frequency and gain, scroll over it to adjust Q, double-click to toggle the band.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        EqGraph {
            Layout.fillWidth: true
            eqState: root.eqState
            bands: root.bands
            selectedBand: root.selectedBand
            onBandSelected: idx => root.selectedBand = idx
            onParamChanged: (symbol, value) => root.queueEqParam(symbol, value)
            onEnableToggled: idx => root.queueEqParam(root.bands[idx].enableSym, root.eqState[root.bands[idx].enableSym] > 0.5 ? 0 : 1)
        }

        SectionHeader {
            text: root.currentBand.name
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            checked: root.eqState[root.currentBand.enableSym] > 0.5
            onToggled: root.queueEqParam(root.currentBand.enableSym, checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Frequency")
            logScale: true
            from: root.currentBand.freqFrom
            to: root.currentBand.freqTo
            decimals: 0
            unit: " Hz"
            paramValue: root.eqState[root.currentBand.freqSym]
            onChanged: v => root.queueEqParam(root.currentBand.freqSym, Math.round(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            last: !root.currentBand.gainSym
            label: qsTr("Q")
            from: root.currentBand.qFrom
            to: root.currentBand.qTo
            decimals: 2
            paramValue: root.eqState[root.currentBand.qSym]
            onChanged: v => root.queueEqParam(root.currentBand.qSym, Math.round(v * 100) / 100)
        }

        ParamSlider {
            Layout.fillWidth: true
            visible: !!root.currentBand.gainSym
            last: true
            label: qsTr("Gain")
            from: -18
            to: 18
            unit: " dB"
            signed: true
            paramValue: root.currentBand.gainSym ? root.eqState[root.currentBand.gainSym] : 0
            onChanged: v => root.queueEqParam(root.currentBand.gainSym, Math.round(v * 10) / 10)
        }

        SectionHeader {
            text: qsTr("Master")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Equalizer enabled")
            checked: root.eqState.enable > 0.5
            onToggled: root.queueEqParam("enable", checked ? 1 : 0)
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
            onChanged: v => root.queueEqParam("gain", Math.round(v * 10) / 10)
        }
    }
}
