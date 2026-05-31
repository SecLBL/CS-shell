pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Caelestia
import Caelestia.Config
import Caelestia.Services

Singleton {
    id: root

    property string previousSinkName: ""
    property string previousSourceName: ""

    property list<PwNode> sinks: []
    property list<PwNode> sources: []
    property list<PwNode> streams: []

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    property PwNode generalOutputDevice: null
    property PwNode chatOutputDevice: null
    property PwNode micInputDevice: null

    property PwNode generalChainOutNode: null
    property PwNode chatChainOutNode: null
    property PwNode micChainOutNode: null

    readonly property var chromashellNodeNames: new Set([
        "MixBus.input", "MixBus.output",
        "MixBusChat.input", "MixBusChat.output",
        "VirtualCable.input", "VirtualCable.output",
        "mic_chain_in", "mic_chain_out",
        "mic_chain_internal_in", "mic_chain_internal_out",
        "chat_chain_in", "chat_chain_out",
        "chat_chain_internal_in", "chat_chain_internal_out",
        "general_chain_in", "general_chain_out",
        "general_chain_internal_in", "general_chain_internal_out",
        "mic-gate", "mic-nr", "mic-comp", "chat-nr", "chat-comp", "general-eq"
    ])

    readonly property bool muted: !!generalChainOutNode?.audio?.muted
    readonly property real volume: generalChainOutNode?.audio?.volume ?? 0

    readonly property bool sourceMuted: !!source?.audio?.muted
    readonly property real sourceVolume: source?.audio?.volume ?? 0

    readonly property bool chatMuted: !!chatChainOutNode?.audio?.muted
    readonly property real chatVolume: chatChainOutNode?.audio?.volume ?? 0

    readonly property bool micMuted: !!micChainOutNode?.audio?.muted
    readonly property real micVolume: micChainOutNode?.audio?.volume ?? 0

    readonly property alias cava: cava
    readonly property alias beatTracker: beatTracker

    function setVolume(newVolume: real): void {
        if (generalChainOutNode?.ready && generalChainOutNode?.audio) {
            generalChainOutNode.audio.muted = false;
            generalChainOutNode.audio.volume = Math.max(0, Math.min(GlobalConfig.services.maxVolume, newVolume));
        }
    }

    function incrementVolume(amount: real): void {
        setVolume(volume + (amount || GlobalConfig.services.audioIncrement));
    }

    function decrementVolume(amount: real): void {
        setVolume(volume - (amount || GlobalConfig.services.audioIncrement));
    }

    function setChatVolume(newVolume: real): void {
        if (chatChainOutNode?.ready && chatChainOutNode?.audio) {
            chatChainOutNode.audio.muted = false;
            chatChainOutNode.audio.volume = Math.max(0, Math.min(GlobalConfig.services.maxVolume, newVolume));
        }
    }

    function incrementChatVolume(amount: real): void {
        setChatVolume(chatVolume + (amount || GlobalConfig.services.audioIncrement));
    }

    function decrementChatVolume(amount: real): void {
        setChatVolume(chatVolume - (amount || GlobalConfig.services.audioIncrement));
    }

    function setMicVolume(newVolume: real): void {
        if (micChainOutNode?.ready && micChainOutNode?.audio) {
            micChainOutNode.audio.muted = false;
            micChainOutNode.audio.volume = Math.max(0, Math.min(GlobalConfig.services.maxVolume, newVolume));
        }
    }

    function incrementMicVolume(amount: real): void {
        setMicVolume(micVolume + (amount || GlobalConfig.services.audioIncrement));
    }

    function decrementMicVolume(amount: real): void {
        setMicVolume(micVolume - (amount || GlobalConfig.services.audioIncrement));
    }

    function setSourceVolume(newVolume: real): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(GlobalConfig.services.maxVolume, newVolume));
        }
    }

    function incrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume + (amount || GlobalConfig.services.audioIncrement));
    }

    function decrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume - (amount || GlobalConfig.services.audioIncrement));
    }

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function _runRoute(bus: string, deviceName: string, oldName: string): void {
        audioRouteProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-route.sh" "$@"',
            "0", bus, deviceName, oldName
        ];
        audioRouteProc.running = false;
        audioRouteProc.running = true;
    }

    function setGeneralOutput(device: PwNode): void {
        const old = generalOutputDevice?.name ?? "";
        generalOutputDevice = device;
        _runRoute("general", device.name, old);
    }

    function setChatOutput(device: PwNode): void {
        const old = chatOutputDevice?.name ?? "";
        chatOutputDevice = device;
        _runRoute("chat", device.name, old);
    }

    function setMicInput(device: PwNode): void {
        const old = micInputDevice?.name ?? "";
        micInputDevice = device;
        _runRoute("mic", device.name, old);
    }

    function cycleNextAudioOutput(): void {
        if (sinks.length === 0)
            return;

        const cur = sinks.findIndex(s => s === generalOutputDevice);
        setGeneralOutput(sinks[(cur + 1) % sinks.length]);
    }

    function setStreamVolume(stream: PwNode, newVolume: real): void {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = false;
            stream.audio.volume = Math.max(0, Math.min(GlobalConfig.services.maxVolume, newVolume));
        }
    }

    function setStreamMuted(stream: PwNode, muted: bool): void {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = muted;
        }
    }

    function getStreamVolume(stream: PwNode): real {
        return stream?.audio?.volume ?? 0;
    }

    function getStreamMuted(stream: PwNode): bool {
        return !!stream?.audio?.muted;
    }

    function getStreamName(stream: PwNode): string {
        if (!stream)
            return qsTr("Unknown");
        // Try application name first, then description, then name
        return stream.properties["application.name"] || stream.description || stream.name || qsTr("Unknown Application");
    }

    onSinkChanged: {
        if (!sink?.ready)
            return;

        const newSinkName = sink.description || sink.name || qsTr("Unknown Device");

        if (previousSinkName && previousSinkName !== newSinkName && GlobalConfig.utilities.toasts.audioOutputChanged)
            Toaster.toast(qsTr("Audio output changed"), qsTr("Now using: %1").arg(newSinkName), "volume_up");

        previousSinkName = newSinkName;
    }

    onSourceChanged: {
        if (!source?.ready)
            return;

        const newSourceName = source.description || source.name || qsTr("Unknown Device");

        if (previousSourceName && previousSourceName !== newSourceName && GlobalConfig.utilities.toasts.audioInputChanged)
            Toaster.toast(qsTr("Audio input changed"), qsTr("Now using: %1").arg(newSourceName), "mic");

        previousSourceName = newSourceName;
    }

    Component.onCompleted: {
        previousSinkName = sink?.description || sink?.name || qsTr("Unknown Device");
        previousSourceName = source?.description || source?.name || qsTr("Unknown Device");
    }

    Connections {
        function onValuesChanged(): void {
            const newSinks = [];
            const newSources = [];
            const newStreams = [];

            for (const node of Pipewire.nodes.values) {
                if (node.name === "general_chain_out") root.generalChainOutNode = node;
                if (node.name === "chat_chain_out")    root.chatChainOutNode    = node;
                if (node.name === "mic_chain_out")     root.micChainOutNode     = node;
                if (root.chromashellNodeNames.has(node.name))
                    continue;
                if (!node.isStream) {
                    if (node.isSink)
                        newSinks.push(node);
                    else if (node.audio)
                        newSources.push(node);
                } else if (node.audio) {
                    newStreams.push(node);
                }
            }

            root.sinks = newSinks;
            root.sources = newSources;
            root.streams = newStreams;
        }

        target: Pipewire.nodes
    }

    PwObjectTracker {
        objects: [
            ...root.sinks, ...root.sources, ...root.streams,
            ...(root.generalChainOutNode ? [root.generalChainOutNode] : []),
            ...(root.chatChainOutNode    ? [root.chatChainOutNode]    : []),
            ...(root.micChainOutNode     ? [root.micChainOutNode]     : [])
        ]
    }

    Process {
        id: audioRouteProc
    }

    CavaProvider {
        id: cava

        bars: GlobalConfig.services.visualiserBars
    }

    BeatTracker {
        id: beatTracker
    }

    IpcHandler {
        function cycleOutput(): void {
            root.cycleNextAudioOutput();
        }

        target: "audio"
    }
}
