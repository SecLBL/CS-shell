pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

// Parameter state of one audio plugin: loads the saved values from
// audio.json and writes changes through audio-param.sh.
Item {
    id: root

    required property string plugin
    // Defaults; saved values are merged over them once loaded
    property var values: ({})

    property var pending: ({})

    visible: false

    // State updates immediately, script writes are batched and flushed
    // sequentially: audio-param.sh does a jq read-modify-write on
    // audio.json, so concurrent invocations during dragging would race.
    function set(symbol: string, value: real): void {
        values = Object.assign({}, values, {
            [symbol]: value
        });
        pending[symbol] = value;
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
                    root.values = Object.assign({}, root.values, JSON.parse(line));
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
            const entries = Object.entries(root.pending);
            if (entries.length === 0)
                return;
            root.pending = {};
            let script = 'P="${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh"';
            for (const [sym, val] of entries)
                script += '; bash "$P" ' + root.plugin + ' ' + sym + ' ' + String(val);
            paramProc.command = ["bash", "-c", script];
            paramProc.running = true;
        }
    }
}
