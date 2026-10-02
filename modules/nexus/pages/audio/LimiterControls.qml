pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// LSP Limiter Stereo controls, reused for the mic ("mic-lim") and chat
// ("chat-lim") chains.
ColumnLayout {
    id: root

    required property string plugin

    readonly property var st: params.values

    function linToDb(v: real): real {
        return 20 * Math.log10(Math.max(v, 0.000001));
    }

    function dbToLin(db: real): real {
        return Math.pow(10, db / 20);
    }

    spacing: Tokens.spacing.extraSmall / 2

    PluginState {
        id: params

        plugin: root.plugin
        values: ({
            enabled: 1,
            th: 0.89125, knee: 1.0, boost: 0,
            lk: 5, at: 5, rt: 5,
            alr: 1, slink: 100,
            g_in: 1.0, g_out: 1.0
        })
    }

    SectionHeader {
        text: qsTr("Limiter")
    }

    ToggleRow {
        Layout.fillWidth: true
        first: true
        text: qsTr("Enabled")
        subtext: qsTr("LSP Limiter Stereo — output ceiling")
        checked: root.st.enabled > 0.5
        onToggled: params.set("enabled", checked ? 1 : 0)
    }

    CollapsibleRows {
        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Threshold")
            from: -48
            to: 0
            unit: " dB"
            paramValue: root.linToDb(root.st.th)
            onChanged: v => params.set("th", root.dbToLin(v))
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Gain boost")
            subtext: qsTr("Raise the output up to the threshold")
            checked: root.st.boost > 0.5
            onToggled: params.set("boost", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Knee")
            from: -12
            to: 12
            unit: " dB"
            signed: true
            paramValue: root.linToDb(root.st.knee)
            onChanged: v => params.set("knee", root.dbToLin(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Lookahead")
            from: 0.1
            to: 20
            unit: " ms"
            paramValue: root.st.lk
            onChanged: v => params.set("lk", Math.round(v * 10) / 10)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Attack")
            from: 0.25
            to: 20
            decimals: 2
            unit: " ms"
            paramValue: root.st.at
            onChanged: v => params.set("at", Math.round(v * 100) / 100)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Release")
            from: 0.25
            to: 20
            decimals: 2
            unit: " ms"
            paramValue: root.st.rt
            onChanged: v => params.set("rt", Math.round(v * 100) / 100)
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Automatic level regulation")
            checked: root.st.alr > 0.5
            onToggled: params.set("alr", checked ? 1 : 0)
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Stereo linking")
            from: 0
            to: 100
            decimals: 0
            unit: " %"
            paramValue: root.st.slink
            onChanged: v => params.set("slink", Math.round(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            label: qsTr("Input gain")
            from: -20
            to: 20
            unit: " dB"
            signed: true
            paramValue: root.linToDb(root.st.g_in)
            onChanged: v => params.set("g_in", root.dbToLin(v))
        }

        ParamSlider {
            Layout.fillWidth: true
            last: true
            label: qsTr("Output gain")
            from: -20
            to: 20
            unit: " dB"
            signed: true
            paramValue: root.linToDb(root.st.g_out)
            onChanged: v => params.set("g_out", root.dbToLin(v))
        }
    }
}
