pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

// LSP Compressor Stereo controls, reused for the mic ("mic-comp") and chat
// ("chat-comp") chains. Owns its own state, loading and parameter writes.
ColumnLayout {
    id: root

    required property string plugin

    property var compState: ({
        enabled: 1, cm: 0,
        al: 0.25119, at: 20, rrl: 0, rt: 100, hold: 0,
        cr: 4.0, kn: 0.50118, mk: 1.0,
        g_in: 1.0, g_out: 1.0, cdw: 100,
        sct: 0, scm: 1, sla: 0, scr: 10, scp: 1.0, scs: 0,
        shpm: 0, shpf: 10, slpm: 0, slpf: 20000,
        bth: 0.000251, bsa: 1.99526
    })

    readonly property list<MenuItem> modeItems: [
        MenuItem {
            text: qsTr("Down")
        },
        MenuItem {
            text: qsTr("Up")
        },
        MenuItem {
            text: qsTr("Boot")
        }
    ]

    readonly property list<MenuItem> scTypeItems: [
        MenuItem {
            text: qsTr("Feed-forward")
        },
        MenuItem {
            text: qsTr("Feed-back")
        },
        MenuItem {
            text: qsTr("Link")
        }
    ]

    readonly property list<MenuItem> scModeItems: [
        MenuItem {
            text: qsTr("Peak")
        },
        MenuItem {
            text: "RMS"
        },
        MenuItem {
            text: "LPF"
        },
        MenuItem {
            text: "SMA"
        }
    ]

    readonly property list<MenuItem> scSourceItems: [
        MenuItem {
            text: qsTr("Mid")
        },
        MenuItem {
            text: qsTr("Side")
        },
        MenuItem {
            text: qsTr("Left")
        },
        MenuItem {
            text: qsTr("Right")
        },
        MenuItem {
            text: qsTr("Min")
        },
        MenuItem {
            text: qsTr("Max")
        }
    ]

    readonly property list<MenuItem> filterSlopeItems: [
        MenuItem {
            text: qsTr("Off")
        },
        MenuItem {
            text: qsTr("12 dB/oct")
        },
        MenuItem {
            text: qsTr("24 dB/oct")
        },
        MenuItem {
            text: qsTr("36 dB/oct")
        }
    ]

    function linToDb(v: real): real {
        return 20 * Math.log10(Math.max(v, 0.000001));
    }

    function dbToLin(db: real): real {
        return Math.pow(10, db / 20);
    }

    function setParam(symbol: string, value: real): void {
        compState = Object.assign({}, compState, {
            [symbol]: value
        });
        paramProc.command = ["bash", "-c", 'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"', "0", plugin, symbol, String(value)];
        paramProc.running = false;
        paramProc.running = true;
    }

    Component.onCompleted: loadProc.running = true

    Process {
        id: loadProc

        command: ["bash", "-c", 'jq -c ".[\\"' + root.plugin + '\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.compState = Object.assign({}, root.compState, JSON.parse(line));
                } catch (e) {}
            }
        }
    }

    Process {
        id: paramProc
    }

    spacing: Tokens.spacing.extraSmall / 2

    SectionHeader {
        text: qsTr("Compressor")
    }

    ToggleRow {
        Layout.fillWidth: true
        first: true
        text: qsTr("Enabled")
        subtext: qsTr("LSP Compressor Stereo — dynamics control")
        checked: root.compState.enabled > 0.5
        onToggled: root.setParam("enabled", checked ? 1 : 0)
    }

    SelectRow {
        Layout.fillWidth: true
        label: qsTr("Mode")
        subtext: qsTr("Downward, upward or boosting compression")
        menuItems: root.modeItems
        active: root.modeItems[Math.round(root.compState.cm)] ?? root.modeItems[0]
        onSelected: item => root.setParam("cm", root.modeItems.indexOf(item))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Threshold")
        from: -60
        to: 0
        unit: " dB"
        paramValue: root.linToDb(root.compState.al)
        onChanged: v => root.setParam("al", root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Attack")
        from: 0
        to: 2000
        unit: " ms"
        paramValue: root.compState.at
        onChanged: v => root.setParam("at", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Hold")
        from: 0
        to: 1000
        unit: " ms"
        paramValue: root.compState.hold
        onChanged: v => root.setParam("hold", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Release")
        from: 0
        to: 5000
        unit: " ms"
        paramValue: root.compState.rt
        onChanged: v => root.setParam("rt", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Release threshold")
        from: -60
        to: 0
        paramValue: root.compState.rrl > 0 ? root.linToDb(root.compState.rrl) : -60
        formatValue: v => v <= -59.9 ? qsTr("Auto") : v.toFixed(1) + " dB"
        onChanged: v => root.setParam("rrl", v <= -59.9 ? 0 : root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Ratio")
        from: 1
        to: 100
        formatValue: v => v.toFixed(1) + ":1"
        paramValue: root.compState.cr
        onChanged: v => root.setParam("cr", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Knee")
        from: 0.0631
        to: 1
        decimals: 3
        paramValue: root.compState.kn
        onChanged: v => root.setParam("kn", Math.round(v * 1000) / 1000)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Makeup")
        from: -40
        to: 40
        unit: " dB"
        signed: true
        paramValue: root.linToDb(root.compState.mk)
        onChanged: v => root.setParam("mk", root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Input gain")
        from: -20
        to: 20
        unit: " dB"
        signed: true
        paramValue: root.linToDb(root.compState.g_in)
        onChanged: v => root.setParam("g_in", root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Output gain")
        from: -20
        to: 20
        unit: " dB"
        signed: true
        paramValue: root.linToDb(root.compState.g_out)
        onChanged: v => root.setParam("g_out", root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        last: true
        label: qsTr("Dry/Wet")
        from: 0
        to: 100
        decimals: 0
        unit: " %"
        paramValue: root.compState.cdw
        onChanged: v => root.setParam("cdw", Math.round(v))
    }

    SectionHeader {
        text: qsTr("Sidechain")
    }

    SelectRow {
        Layout.fillWidth: true
        first: true
        label: qsTr("Type")
        menuItems: root.scTypeItems
        active: root.scTypeItems[Math.round(root.compState.sct)] ?? root.scTypeItems[0]
        onSelected: item => root.setParam("sct", root.scTypeItems.indexOf(item))
    }

    SelectRow {
        Layout.fillWidth: true
        label: qsTr("Mode")
        menuItems: root.scModeItems
        active: root.scModeItems[Math.round(root.compState.scm)] ?? root.scModeItems[0]
        onSelected: item => root.setParam("scm", root.scModeItems.indexOf(item))
    }

    SelectRow {
        Layout.fillWidth: true
        label: qsTr("Source")
        menuItems: root.scSourceItems
        active: root.scSourceItems[Math.round(root.compState.scs)] ?? root.scSourceItems[0]
        onSelected: item => root.setParam("scs", root.scSourceItems.indexOf(item))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Lookahead")
        from: 0
        to: 20
        unit: " ms"
        paramValue: root.compState.sla
        onChanged: v => root.setParam("sla", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("Reactivity")
        from: 0
        to: 250
        unit: " ms"
        paramValue: root.compState.scr
        onChanged: v => root.setParam("scr", Math.round(v * 10) / 10)
    }

    ParamSlider {
        Layout.fillWidth: true
        last: true
        label: qsTr("Preamp")
        from: -40
        to: 40
        unit: " dB"
        signed: true
        paramValue: root.linToDb(root.compState.scp)
        onChanged: v => root.setParam("scp", root.dbToLin(v))
    }

    SectionHeader {
        text: qsTr("Sidechain filters")
    }

    SelectRow {
        Layout.fillWidth: true
        first: true
        label: qsTr("High-pass slope")
        menuItems: root.filterSlopeItems
        active: root.filterSlopeItems[Math.round(root.compState.shpm)] ?? root.filterSlopeItems[0]
        onSelected: item => root.setParam("shpm", root.filterSlopeItems.indexOf(item))
    }

    ParamSlider {
        Layout.fillWidth: true
        label: qsTr("High-pass frequency")
        logScale: true
        from: 10
        to: 20000
        decimals: 0
        unit: " Hz"
        enabled: root.compState.shpm > 0.5
        opacity: enabled ? 1 : 0.4
        paramValue: root.compState.shpf
        onChanged: v => root.setParam("shpf", Math.round(v))
    }

    SelectRow {
        Layout.fillWidth: true
        label: qsTr("Low-pass slope")
        menuItems: root.filterSlopeItems
        active: root.filterSlopeItems[Math.round(root.compState.slpm)] ?? root.filterSlopeItems[0]
        onSelected: item => root.setParam("slpm", root.filterSlopeItems.indexOf(item))
    }

    ParamSlider {
        Layout.fillWidth: true
        last: true
        label: qsTr("Low-pass frequency")
        logScale: true
        from: 10
        to: 20000
        decimals: 0
        unit: " Hz"
        enabled: root.compState.slpm > 0.5
        opacity: enabled ? 1 : 0.4
        paramValue: root.compState.slpf
        onChanged: v => root.setParam("slpf", Math.round(v))
    }

    SectionHeader {
        text: qsTr("Boost (Boot mode)")
    }

    ParamSlider {
        Layout.fillWidth: true
        first: true
        label: qsTr("Boost threshold")
        from: -120
        to: -60
        unit: " dB"
        enabled: Math.round(root.compState.cm) === 2
        opacity: enabled ? 1 : 0.4
        paramValue: root.linToDb(root.compState.bth)
        onChanged: v => root.setParam("bth", root.dbToLin(v))
    }

    ParamSlider {
        Layout.fillWidth: true
        last: true
        label: qsTr("Boost amount")
        from: -40
        to: 40
        unit: " dB"
        signed: true
        enabled: Math.round(root.compState.cm) === 2
        opacity: enabled ? 1 : 0.4
        paramValue: root.linToDb(root.compState.bsa)
        onChanged: v => root.setParam("bsa", root.dbToLin(v))
    }
}
