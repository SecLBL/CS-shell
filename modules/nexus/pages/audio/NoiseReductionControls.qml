pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// DeepFilterNet controls, reused for the mic ("mic-nr") and chat
// ("chat-nr") chains. Owns its own state, loading and parameter writes.
ColumnLayout {
    id: root

    required property string plugin
    property alias first: header.first

    property var nrState: ({
        enabled: 1,
        attenuation: 100,
        postfilter_beta: 0.02,
        min_db: -15, max_erb_db: 35, max_df_db: 35,
        min_buffer: 0
    })

    readonly property bool on: nrState.enabled > 0.5

    property var pendingParams: ({})

    // State updates immediately, script writes are batched and flushed
    // sequentially: audio-param.sh does a jq read-modify-write on
    // audio.json, so concurrent invocations during dragging would race.
    function setParam(symbol: string, value: real): void {
        nrState = Object.assign({}, nrState, {
            [symbol]: value
        });
        pendingParams[symbol] = value;
        if (!flushTimer.running)
            flushTimer.start();
    }

    Component.onCompleted: loadProc.running = true

    Process {
        id: loadProc

        command: ["bash", "-c", 'jq -c ".[\\"' + root.plugin + '\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.nrState = Object.assign({}, root.nrState, JSON.parse(line));
                } catch (e) {}
            }
        }
    }

    Process {
        id: paramProc
    }

    Timer {
        id: flushTimer

        interval: 80
        onTriggered: {
            if (paramProc.running) {
                restart();
                return;
            }
            const entries = Object.entries(root.pendingParams);
            if (entries.length === 0)
                return;
            root.pendingParams = {};
            let script = 'P="${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh"';
            for (const [sym, val] of entries)
                script += '; bash "$P" ' + root.plugin + ' ' + sym + ' ' + String(val);
            paramProc.command = ["bash", "-c", script];
            paramProc.running = true;
        }
    }

    spacing: Tokens.spacing.extraSmall / 2

    SectionHeader {
        id: header

        text: qsTr("Noise reduction")
    }

    ToggleRow {
        Layout.fillWidth: true
        first: true
        text: qsTr("Enabled")
        subtext: qsTr("DeepFilterNet — deep learning noise suppression")
        checked: root.on
        onToggled: root.setParam("enabled", checked ? 1 : 0)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Attenuation limit")
        from: 0
        to: 100
        decimals: 0
        unit: " dB"
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.attenuation
        onChanged: v => root.setParam("attenuation", Math.round(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Post filter")
        from: 0
        to: 0.05
        decimals: 3
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.postfilter_beta
        onChanged: v => root.setParam("postfilter_beta", Math.round(v * 1000) / 1000)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Min threshold")
        from: -15
        to: 35
        decimals: 0
        unit: " dB"
        signed: true
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.min_db
        onChanged: v => root.setParam("min_db", Math.round(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Max ERB threshold")
        from: -15
        to: 35
        decimals: 0
        unit: " dB"
        signed: true
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.max_erb_db
        onChanged: v => root.setParam("max_erb_db", Math.round(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Max DF threshold")
        from: -15
        to: 35
        decimals: 0
        unit: " dB"
        signed: true
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.max_df_db
        onChanged: v => root.setParam("max_df_db", Math.round(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        last: true
        label: qsTr("Min buffer")
        from: 0
        to: 10
        decimals: 0
        unit: qsTr(" frames")
        enabled: root.on
        opacity: enabled ? 1 : 0.4
        paramValue: root.nrState.min_buffer
        onChanged: v => root.setParam("min_buffer", Math.round(v))
    }
}
