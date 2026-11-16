pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Caelestia
import Caelestia.Config
import qs.services
import qs.utils

// Replay buffer (instant replay) driven by `caelestia replay`, which owns the recorder
// process so the buffer survives shell restarts. Runs independently of Recorder.
Singleton {
    id: root

    readonly property var conf: GlobalConfig.capture
    readonly property string stateDir: `${Paths.state}/replay`

    property var state: ({})
    property bool running: false
    property real rssMb: 0
    property int refCount
    readonly property alias autoReason: props.autoReason

    readonly property int length: state.length ?? conf.replay.length
    readonly property string lastSaved: state.lastSaved ?? ""
    readonly property string clipsDir: conf.clipsDir ? Paths.absolutePath(conf.clipsDir) : (Quickshell.env("CAELESTIA_CLIPS_DIR") || `${Paths.videos}/Clips`)
    readonly property string recordingsDir: conf.recordingsDir ? Paths.absolutePath(conf.recordingsDir) : Paths.recsdir

    // Autostart app list as regexes; invalid entries are skipped
    readonly property var appRegexes: conf.autostart.apps.filter(a => a).map(a => {
        try {
            return new RegExp(a, "i");
        } catch (e) {
            return null;
        }
    }).filter(r => r)
    // Open windows matching the autostart app list
    readonly property int appMatches: appRegexes.length ? Hypr.toplevels.values.filter(t => {
        const cls = t.wayland?.appId ?? t.lastIpcObject?.class ?? "";
        return cls && appRegexes.some(r => r.test(cls));
    }).length : 0

    // The recorder names its capture streams gsr-<source>; their volume sets the track's recording level
    readonly property var trackOfSource: ({
            "MixBus.input.monitor": "system",
            "general_chain_out": "system",
            "default_output": "system",
            "MixBusChat.input.monitor": "chat",
            "chat_chain_out": "chat",
            "mic_chain_in.monitor": "mic",
            "mic_chain_out": "mic",
            "default_input": "mic"
        })
    readonly property list<PwNode> recorderStreams: Pipewire.nodes.values.filter(n => n.isStream && n.name.startsWith("gsr-"))

    // Any autostart rule that currently wants the buffer on; shell start holds for the whole session
    readonly property bool ruleHolds: conf.autostart.enabled && (conf.autostart.onShellStart || (conf.autostart.onGameMode && GameMode.enabled) || appMatches > 0 || props.appLatched)

    property bool initialised
    property real lastSavedAt

    signal clipSaved(path: string)

    function formatDuration(secs: int): string {
        if (secs < 60)
            return qsTr("%1 s").arg(secs);
        if (secs < 3600)
            return secs % 60 ? `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, "0")} min` : qsTr("%1 min").arg(secs / 60);
        return qsTr("%1 h").arg(Math.round(secs / 360) / 10);
    }

    function formatSize(bytes: real): string {
        if (bytes >= 1024 ** 3)
            return `${(bytes / 1024 ** 3).toFixed(1)} GB`;
        return `${Math.round(bytes / 1024 ** 2)} MB`;
    }

    function command(args: list<string>): void {
        cmdProc.exec(["caelestia", "replay", ...args]);
    }

    function start(): void {
        props.autoReason = "";
        command(["start"]);
    }

    function stop(): void {
        props.autoReason = "";
        command(["stop"]);
    }

    function toggle(): void {
        running ? stop() : start();
    }

    function restart(): void {
        command(["restart"]);
    }

    function save(seconds: int): void {
        command(["save", String(seconds ?? 0)]);
    }

    function autoStart(reason: string): void {
        if (!conf.autostart.enabled || running || cmdProc.running)
            return;
        props.autoReason = reason;
        command(["start"]);
    }

    // Stops only what a rule started, and only once no rule wants the buffer anymore
    function autoStop(): void {
        if (props.autoReason && running && !ruleHolds)
            stop();
    }

    function check(): void {
        if (state.pid) {
            checkProc.running = true;
        } else {
            running = false;
            init();
        }
    }

    function init(): void {
        if (initialised)
            return;
        initialised = true;
        if (conf.autostart.onShellStart)
            autoStart("shell");
        else if (appMatches > 0)
            autoStart("app");
    }

    onRunningChanged: {
        if (!running) {
            props.autoReason = "";
            props.appLatched = false;
        }
        if (initialised && conf.toasts)
            Toaster.toast(running ? qsTr("Replay buffer on") : qsTr("Replay buffer off"), running ? qsTr("Recording the last %1 s").arg(length) : qsTr("Clips are no longer recorded"), "replay");
    }

    onAppMatchesChanged: {
        if (!initialised)
            return;
        if (appMatches > 0) {
            autoStart("app");
            // Without "stop when they close" the app keeps holding the buffer after it exits
            props.appLatched = !conf.autostart.stopWithApps;
        } else {
            autoStop();
        }
    }

    PersistentProperties {
        id: props

        // What started the buffer automatically: shell, app or gameMode; empty when started by hand
        property string autoReason
        property bool appLatched

        reloadableId: "replay"
    }

    FileView {
        path: `${root.stateDir}/state.json`
        watchChanges: true
        printErrors: false // missing until the first start
        onFileChanged: reload()
        onLoaded: {
            try {
                root.state = JSON.parse(text());
            } catch (e) {
                root.state = {};
            }
            const saved = root.state.lastSavedAt ?? 0;
            if (root.initialised && saved > root.lastSavedAt)
                root.clipSaved(root.state.lastSaved);
            root.lastSavedAt = saved;
            root.check();
        }
        onLoadFailed: {
            root.state = {};
            root.check();
        }
    }

    // Checks the pid still belongs to the recorder and reads its memory use
    Process {
        id: checkProc

        command: ["sh", "-c", "grep -qa gpu-screen-recorder /proc/$0/cmdline && grep VmRSS /proc/$0/status", String(root.state.pid ?? 0)]
        stdout: StdioCollector {
            onStreamFinished: {
                const kb = parseInt(text.replace(/\D+/g, " ").trim());
                root.rssMb = kb ? kb / 1024 : 0;
            }
        }
        onExited: code => { // qmllint disable signal-handler-parameters
            root.running = code === 0;
            root.init();
        }
    }

    Process {
        id: cmdProc

        onExited: root.check() // qmllint disable signal-handler-parameters
    }

    // Detects a crashed recorder; faster while something shows the memory use
    Timer {
        interval: root.refCount > 0 ? 2000 : 10000
        running: !!root.state.pid
        repeat: true
        onTriggered: checkProc.running = true
    }

    Connections {
        function onEnabledChanged(): void {
            if (GameMode.enabled && root.conf.autostart.onGameMode)
                root.autoStart("gameMode");
            else if (!GameMode.enabled)
                root.autoStop();
        }

        target: GameMode
    }

    PwObjectTracker {
        objects: root.recorderStreams
    }

    Variants {
        model: root.recorderStreams

        QtObject {
            required property PwNode modelData
            readonly property string track: root.trackOfSource[modelData?.name.slice(4) ?? ""] ?? ""
            readonly property real volume: track ? root.conf.audio[`${track}Volume`] : -1
            readonly property bool ready: !!modelData?.ready && !!modelData?.audio
            readonly property real actual: modelData?.audio?.volume ?? -1

            // WirePlumber restores the last stream volume after creation, so keep enforcing ours
            function apply(): void {
                if (ready && volume >= 0 && Math.abs(actual - volume) > 0.005)
                    modelData.audio.volume = volume;
            }

            onVolumeChanged: apply()
            onReadyChanged: apply()
            onActualChanged: Qt.callLater(apply)
            Component.onCompleted: apply()
        }
    }

    IpcHandler {
        function toggle(): void {
            root.toggle();
        }

        function start(): void {
            root.start();
        }

        function stop(): void {
            root.stop();
        }

        function save(seconds: int): void {
            root.save(seconds);
        }

        function isRunning(): bool {
            return root.running;
        }

        target: "replay"
    }
}
