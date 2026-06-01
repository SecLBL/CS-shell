pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import Quickshell.Io

Item {
    id: root

    required property Session session

    anchors.fill: parent

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
        eqState = Object.assign({}, eqState, { [symbol]: value });
        eqParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "general-eq", symbol, String(value)
        ];
        eqParamProc.running = false;
        eqParamProc.running = true;
    }

    Process {
        id: eqLoadProc
        command: ["bash", "-c",
            'jq -c ".[\\"general-eq\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try { root.eqState = Object.assign({}, root.eqState, JSON.parse(line)); } catch(e) {}
            }
        }
    }

    Process { id: eqParamProc }

    function linToDb(v: real): real { return 20 * Math.log10(Math.max(v, 0.000001)); }
    function dbToLin(db: real): real { return Math.pow(10, db / 20); }

    property var gateState: ({
        gt: 0.01, gz: 0.59566, gh: 0, ht: 0.25119, hz: 0.50119,
        gr: 0.000251, mk: 1.41254, at: 2.92, rt: 100, hold: 171
    })

    function setGateParam(symbol: string, value: real): void {
        gateState = Object.assign({}, gateState, { [symbol]: value });
        gateParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "mic-gate", symbol, String(value)
        ];
        gateParamProc.running = false;
        gateParamProc.running = true;
    }

    Process {
        id: gateLoadProc
        command: ["bash", "-c",
            'jq -c ".[\\"mic-gate\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try { root.gateState = Object.assign({}, root.gateState, JSON.parse(line)); } catch(e) {}
            }
        }
    }

    Process { id: gateParamProc }

    property bool nrEnabled: true

    function setNrEnabled(val: bool): void {
        nrEnabled = val;
        nrParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "mic-nr", "enabled", val ? "1" : "0"
        ];
        nrParamProc.running = false;
        nrParamProc.running = true;
    }

    Process {
        id: nrLoadProc
        command: ["bash", "-c",
            'jq -r ".[\\"mic-nr\\"].params.enabled // 1" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line.trim());
                if (!isNaN(v)) root.nrEnabled = v !== 0;
            }
        }
    }

    Process { id: nrParamProc }

    property var compState: ({
        enabled: 1, cm: 0,
        al: 0.25119, at: 20, rrl: 0, rt: 100, hold: 0,
        cr: 4.0, kn: 0.50118, mk: 1.0,
        g_in: 1.0, g_out: 1.0, cdw: 100,
        sct: 0, scm: 1, sla: 0, scr: 10, scp: 1.0, scs: 0,
        shpm: 0, shpf: 10, slpm: 0, slpf: 20000,
        bth: 0.000251, bsa: 1.99526
    })

    function setCompParam(symbol: string, value: real): void {
        compState = Object.assign({}, compState, { [symbol]: value });
        compParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "mic-comp", symbol, String(value)
        ];
        compParamProc.running = false;
        compParamProc.running = true;
    }

    Process {
        id: compLoadProc
        command: ["bash", "-c",
            'jq -c ".[\\"mic-comp\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try { root.compState = Object.assign({}, root.compState, JSON.parse(line)); } catch(e) {}
            }
        }
    }

    Process { id: compParamProc }

    property bool chatNrEnabled: true

    function setChatNrEnabled(val: bool): void {
        chatNrEnabled = val;
        chatNrParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "chat-nr", "enabled", val ? "1" : "0"
        ];
        chatNrParamProc.running = false;
        chatNrParamProc.running = true;
    }

    Process {
        id: chatNrLoadProc
        command: ["bash", "-c",
            'jq -r ".[\\"chat-nr\\"].params.enabled // 1" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line.trim());
                if (!isNaN(v)) root.chatNrEnabled = v !== 0;
            }
        }
    }

    Process { id: chatNrParamProc }

    property var chatCompState: ({
        enabled: 1, cm: 0,
        al: 0.25119, at: 20, rrl: 0, rt: 100, hold: 0,
        cr: 4.0, kn: 0.50118, mk: 1.0,
        g_in: 1.0, g_out: 1.0, cdw: 100,
        sct: 0, scm: 1, sla: 0, scr: 10, scp: 1.0, scs: 0,
        shpm: 0, shpf: 10, slpm: 0, slpf: 20000,
        bth: 0.000251, bsa: 1.99526
    })

    function setChatCompParam(symbol: string, value: real): void {
        chatCompState = Object.assign({}, chatCompState, { [symbol]: value });
        chatCompParamProc.command = [
            "bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" "$@"',
            "0", "chat-comp", symbol, String(value)
        ];
        chatCompParamProc.running = false;
        chatCompParamProc.running = true;
    }

    Process {
        id: chatCompLoadProc
        command: ["bash", "-c",
            'jq -c ".[\\"chat-comp\\"].params // {}" "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/runtime/audio.json"']
        stdout: SplitParser {
            onRead: line => {
                try { root.chatCompState = Object.assign({}, root.chatCompState, JSON.parse(line)); } catch(e) {}
            }
        }
    }

    Process { id: chatCompParamProc }

    Component.onCompleted: {
        eqLoadProc.running = true;
        gateLoadProc.running = true;
        nrLoadProc.running = true;
        compLoadProc.running = true;
        chatNrLoadProc.running = true;
        chatCompLoadProc.running = true;
    }

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {
            StyledFlickable {
                id: leftAudioFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftContent.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftAudioFlickable
                }

                ColumnLayout {
                    id: leftContent

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Tokens.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.smaller

                        StyledText {
                            text: qsTr("Audio")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 500
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    CollapsibleSection {
                        id: generalOutputSection

                        Layout.fillWidth: true
                        title: qsTr("General output")
                        expanded: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: qsTr("Routes MixBus to the selected device")
                                color: Colours.palette.m3outline
                            }

                            Repeater {
                                Layout.fillWidth: true
                                model: Audio.sinks

                                delegate: StyledRect {
                                    required property var modelData

                                    Layout.fillWidth: true

                                    color: Audio.generalOutputDevice?.id === modelData.id ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
                                    radius: Tokens.rounding.normal
                                    implicitHeight: generalOutputRow.implicitHeight + Tokens.padding.normal * 2

                                    StateLayer {
                                        onClicked: Audio.setGeneralOutput(modelData)
                                    }

                                    RowLayout {
                                        id: generalOutputRow

                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: Tokens.padding.normal

                                        spacing: Tokens.spacing.normal

                                        MaterialIcon {
                                            text: Audio.generalOutputDevice?.id === modelData.id ? "speaker" : "speaker_group"
                                            font.pointSize: Tokens.font.size.large
                                            fill: Audio.generalOutputDevice?.id === modelData.id ? 1 : 0
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            maximumLineCount: 1

                                            text: modelData.description || qsTr("Unknown")
                                            font.weight: Audio.generalOutputDevice?.id === modelData.id ? 500 : 400
                                        }
                                    }
                                }
                            }
                        }
                    }

                    CollapsibleSection {
                        id: chatOutputSection

                        Layout.fillWidth: true
                        title: qsTr("Chat output")
                        expanded: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: qsTr("Routes processed chat audio to the selected device")
                                color: Colours.palette.m3outline
                            }

                            Repeater {
                                Layout.fillWidth: true
                                model: Audio.sinks

                                delegate: StyledRect {
                                    required property var modelData

                                    Layout.fillWidth: true

                                    color: Audio.chatOutputDevice?.id === modelData.id ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
                                    radius: Tokens.rounding.normal
                                    implicitHeight: chatOutputRow.implicitHeight + Tokens.padding.normal * 2

                                    StateLayer {
                                        onClicked: Audio.setChatOutput(modelData)
                                    }

                                    RowLayout {
                                        id: chatOutputRow

                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: Tokens.padding.normal

                                        spacing: Tokens.spacing.normal

                                        MaterialIcon {
                                            text: Audio.chatOutputDevice?.id === modelData.id ? "headphones" : "headset"
                                            font.pointSize: Tokens.font.size.large
                                            fill: Audio.chatOutputDevice?.id === modelData.id ? 1 : 0
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            maximumLineCount: 1

                                            text: modelData.description || qsTr("Unknown")
                                            font.weight: Audio.chatOutputDevice?.id === modelData.id ? 500 : 400
                                        }
                                    }
                                }
                            }
                        }
                    }

                    CollapsibleSection {
                        id: micInputSection

                        Layout.fillWidth: true
                        title: qsTr("Mic input")
                        expanded: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: qsTr("Routes device into mic processing chain")
                                color: Colours.palette.m3outline
                            }

                            Repeater {
                                Layout.fillWidth: true
                                model: Audio.sources

                                delegate: StyledRect {
                                    required property var modelData

                                    Layout.fillWidth: true

                                    color: Audio.micInputDevice?.id === modelData.id ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
                                    radius: Tokens.rounding.normal
                                    implicitHeight: micInputRow.implicitHeight + Tokens.padding.normal * 2

                                    StateLayer {
                                        onClicked: Audio.setMicInput(modelData)
                                    }

                                    RowLayout {
                                        id: micInputRow

                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: Tokens.padding.normal

                                        spacing: Tokens.spacing.normal

                                        MaterialIcon {
                                            text: "mic"
                                            font.pointSize: Tokens.font.size.large
                                            fill: Audio.micInputDevice?.id === modelData.id ? 1 : 0
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            maximumLineCount: 1

                                            text: modelData.description || qsTr("Unknown")
                                            font.weight: Audio.micInputDevice?.id === modelData.id ? 500 : 400
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        rightContent: Component {
            StyledFlickable {
                id: rightAudioFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: contentLayout.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: rightAudioFlickable
                }

                ColumnLayout {
                    id: contentLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: Tokens.spacing.normal

                    SettingsHeader {
                        icon: "volume_up"
                        title: qsTr("Audio Settings")
                    }

                    SectionHeader {
                        title: qsTr("General output volume")
                        description: qsTr("general_chain_out — after EQ, all apps routing to the main output")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText {
                                    text: qsTr("Volume")
                                    font.pointSize: Tokens.font.size.normal
                                    font.weight: 500
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                StyledInputField {
                                    id: outputVolumeInput

                                    Layout.preferredWidth: 70
                                    validator: IntValidator {
                                        bottom: 0
                                        top: 100
                                    }
                                    enabled: !Audio.muted

                                    Component.onCompleted: {
                                        text = Math.round(Audio.volume * 100).toString();
                                    }

                                    onTextEdited: text => {
                                        if (hasFocus) {
                                            const val = parseInt(text);
                                            if (!isNaN(val) && val >= 0 && val <= 100) {
                                                Audio.setVolume(val / 100);
                                            }
                                        }
                                    }

                                    onEditingFinished: {
                                        const val = parseInt(text);
                                        if (isNaN(val) || val < 0 || val > 100) {
                                            text = Math.round(Audio.volume * 100).toString();
                                        }
                                    }

                                    Connections {
                                        function onVolumeChanged() {
                                            if (!outputVolumeInput.hasFocus) {
                                                outputVolumeInput.text = Math.round(Audio.volume * 100).toString();
                                            }
                                        }

                                        target: Audio
                                    }
                                }

                                StyledText {
                                    text: "%"
                                    color: Colours.palette.m3outline
                                    font.pointSize: Tokens.font.size.normal
                                    opacity: Audio.muted ? 0.5 : 1
                                }

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: muteGeneralIcon.implicitHeight + Tokens.padding.normal * 2

                                    radius: Tokens.rounding.normal
                                    color: Audio.muted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                    StateLayer {
                                        onClicked: {
                                            if (Audio.generalChainOutNode?.audio) {
                                                Audio.generalChainOutNode.audio.muted = !Audio.generalChainOutNode.audio.muted;
                                            }
                                        }
                                    }

                                    MaterialIcon {
                                        id: muteGeneralIcon

                                        anchors.centerIn: parent
                                        text: Audio.muted ? "volume_off" : "volume_up"
                                        color: Audio.muted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                    }
                                }
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                implicitHeight: Tokens.padding.normal * 3

                                value: Audio.volume
                                enabled: !Audio.muted
                                opacity: enabled ? 1 : 0.5
                                onMoved: {
                                    Audio.setVolume(value);
                                    if (!outputVolumeInput.hasFocus) {
                                        outputVolumeInput.text = Math.round(value * 100).toString();
                                    }
                                }
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Chat output volume")
                        description: qsTr("chat_chain_out — after noise reduction and compression")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText {
                                    text: qsTr("Volume")
                                    font.pointSize: Tokens.font.size.normal
                                    font.weight: 500
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                StyledInputField {
                                    id: chatVolumeInput

                                    Layout.preferredWidth: 70
                                    validator: IntValidator {
                                        bottom: 0
                                        top: 100
                                    }
                                    enabled: !Audio.chatMuted

                                    Component.onCompleted: {
                                        text = Math.round(Audio.chatVolume * 100).toString();
                                    }

                                    onTextEdited: text => {
                                        if (hasFocus) {
                                            const val = parseInt(text);
                                            if (!isNaN(val) && val >= 0 && val <= 100) {
                                                Audio.setChatVolume(val / 100);
                                            }
                                        }
                                    }

                                    onEditingFinished: {
                                        const val = parseInt(text);
                                        if (isNaN(val) || val < 0 || val > 100) {
                                            text = Math.round(Audio.chatVolume * 100).toString();
                                        }
                                    }

                                    Connections {
                                        function onChatVolumeChanged() {
                                            if (!chatVolumeInput.hasFocus) {
                                                chatVolumeInput.text = Math.round(Audio.chatVolume * 100).toString();
                                            }
                                        }

                                        target: Audio
                                    }
                                }

                                StyledText {
                                    text: "%"
                                    color: Colours.palette.m3outline
                                    font.pointSize: Tokens.font.size.normal
                                    opacity: Audio.chatMuted ? 0.5 : 1
                                }

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: muteChatIcon.implicitHeight + Tokens.padding.normal * 2

                                    radius: Tokens.rounding.normal
                                    color: Audio.chatMuted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                    StateLayer {
                                        onClicked: {
                                            if (Audio.chatChainOutNode?.audio) {
                                                Audio.chatChainOutNode.audio.muted = !Audio.chatChainOutNode.audio.muted;
                                            }
                                        }
                                    }

                                    MaterialIcon {
                                        id: muteChatIcon

                                        anchors.centerIn: parent
                                        text: Audio.chatMuted ? "volume_off" : "headphones"
                                        color: Audio.chatMuted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                    }
                                }
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                implicitHeight: Tokens.padding.normal * 3

                                value: Audio.chatVolume
                                enabled: !Audio.chatMuted
                                opacity: enabled ? 1 : 0.5
                                onMoved: {
                                    Audio.setChatVolume(value);
                                    if (!chatVolumeInput.hasFocus) {
                                        chatVolumeInput.text = Math.round(value * 100).toString();
                                    }
                                }

                                Connections {
                                    function onChatVolumeChanged() {
                                        value = Audio.chatVolume;
                                    }

                                    target: Audio
                                }
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Mic input volume")
                        description: qsTr("mic_chain_out — processed mic signal sent to apps")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText {
                                    text: qsTr("Volume")
                                    font.pointSize: Tokens.font.size.normal
                                    font.weight: 500
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                StyledInputField {
                                    id: micVolumeInput

                                    Layout.preferredWidth: 70
                                    validator: IntValidator {
                                        bottom: 0
                                        top: 100
                                    }
                                    enabled: !Audio.micMuted

                                    Component.onCompleted: {
                                        text = Math.round(Audio.micVolume * 100).toString();
                                    }

                                    onTextEdited: text => {
                                        if (hasFocus) {
                                            const val = parseInt(text);
                                            if (!isNaN(val) && val >= 0 && val <= 100) {
                                                Audio.setMicVolume(val / 100);
                                            }
                                        }
                                    }

                                    onEditingFinished: {
                                        const val = parseInt(text);
                                        if (isNaN(val) || val < 0 || val > 100) {
                                            text = Math.round(Audio.micVolume * 100).toString();
                                        }
                                    }

                                    Connections {
                                        function onMicVolumeChanged() {
                                            if (!micVolumeInput.hasFocus) {
                                                micVolumeInput.text = Math.round(Audio.micVolume * 100).toString();
                                            }
                                        }

                                        target: Audio
                                    }
                                }

                                StyledText {
                                    text: "%"
                                    color: Colours.palette.m3outline
                                    font.pointSize: Tokens.font.size.normal
                                    opacity: Audio.micMuted ? 0.5 : 1
                                }

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: muteMicIcon.implicitHeight + Tokens.padding.normal * 2

                                    radius: Tokens.rounding.normal
                                    color: Audio.micMuted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                    StateLayer {
                                        onClicked: {
                                            if (Audio.micChainOutNode?.audio) {
                                                Audio.micChainOutNode.audio.muted = !Audio.micChainOutNode.audio.muted;
                                            }
                                        }
                                    }

                                    MaterialIcon {
                                        id: muteMicIcon

                                        anchors.centerIn: parent
                                        text: Audio.micMuted ? "mic_off" : "mic"
                                        color: Audio.micMuted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                    }
                                }
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                implicitHeight: Tokens.padding.normal * 3

                                value: Audio.micVolume
                                enabled: !Audio.micMuted
                                opacity: enabled ? 1 : 0.5
                                onMoved: {
                                    Audio.setMicVolume(value);
                                    if (!micVolumeInput.hasFocus) {
                                        micVolumeInput.text = Math.round(value * 100).toString();
                                    }
                                }

                                Connections {
                                    function onMicVolumeChanged() {
                                        value = Audio.micVolume;
                                    }

                                    target: Audio
                                }
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Applications")
                        description: qsTr("Control volume for individual applications")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            Repeater {
                                model: Audio.streams
                                Layout.fillWidth: true

                                delegate: ColumnLayout {
                                    required property var modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    spacing: Tokens.spacing.smaller

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Tokens.spacing.normal

                                        MaterialIcon {
                                            text: "apps"
                                            font.pointSize: Tokens.font.size.normal
                                            fill: 0
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            text: Audio.getStreamName(modelData)
                                            font.pointSize: Tokens.font.size.normal
                                            font.weight: 500
                                        }

                                        StyledInputField {
                                            id: streamVolumeInput

                                            Layout.preferredWidth: 70
                                            validator: IntValidator {
                                                bottom: 0
                                                top: 100
                                            }
                                            enabled: !Audio.getStreamMuted(modelData)

                                            Component.onCompleted: {
                                                text = Math.round(Audio.getStreamVolume(modelData) * 100).toString();
                                            }

                                            onTextEdited: text => {
                                                if (hasFocus) {
                                                    const val = parseInt(text);
                                                    if (!isNaN(val) && val >= 0 && val <= 100) {
                                                        Audio.setStreamVolume(modelData, val / 100);
                                                    }
                                                }
                                            }

                                            onEditingFinished: {
                                                const val = parseInt(text);
                                                if (isNaN(val) || val < 0 || val > 100) {
                                                    text = Math.round(Audio.getStreamVolume(modelData) * 100).toString();
                                                }
                                            }

                                            Connections {
                                                function onVolumeChanged() {
                                                    if (!streamVolumeInput.hasFocus) {
                                                        streamVolumeInput.text = Math.round(modelData.audio.volume * 100).toString();
                                                    }
                                                }

                                                target: modelData.audio
                                            }
                                        }

                                        StyledText {
                                            text: "%"
                                            color: Colours.palette.m3outline
                                            font.pointSize: Tokens.font.size.normal
                                            opacity: Audio.getStreamMuted(modelData) ? 0.5 : 1
                                        }

                                        StyledRect {
                                            implicitWidth: implicitHeight
                                            implicitHeight: streamMuteIcon.implicitHeight + Tokens.padding.normal * 2

                                            radius: Tokens.rounding.normal
                                            color: Audio.getStreamMuted(modelData) ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                            StateLayer {
                                                onClicked: {
                                                    Audio.setStreamMuted(modelData, !Audio.getStreamMuted(modelData));
                                                }
                                            }

                                            MaterialIcon {
                                                id: streamMuteIcon

                                                anchors.centerIn: parent
                                                text: Audio.getStreamMuted(modelData) ? "volume_off" : "volume_up"
                                                color: Audio.getStreamMuted(modelData) ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                            }
                                        }
                                    }

                                    StyledSlider {
                                        Layout.fillWidth: true
                                        implicitHeight: Tokens.padding.normal * 3

                                        value: Audio.getStreamVolume(modelData)
                                        enabled: !Audio.getStreamMuted(modelData)
                                        opacity: enabled ? 1 : 0.5
                                        onMoved: {
                                            Audio.setStreamVolume(modelData, value);
                                            if (!streamVolumeInput.hasFocus) {
                                                streamVolumeInput.text = Math.round(value * 100).toString();
                                            }
                                        }

                                        Connections {
                                            function onVolumeChanged() {
                                                value = modelData.audio.volume;
                                            }

                                            target: modelData.audio
                                        }
                                    }
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                visible: Audio.streams.length === 0
                                text: qsTr("No applications currently playing audio")
                                color: Colours.palette.m3outline
                                font.pointSize: Tokens.font.size.small
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Equalizer")
                        description: qsTr("fil4 parametric EQ — applied to general output")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            // ── Master ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: masterGainInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.enable ? Colours.palette.m3primary
                                                               : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "power_settings_new"
                                        fill: root.eqState.enable ? 1 : 0
                                        color: root.eqState.enable ? Colours.palette.m3onPrimary
                                                                   : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("enable", root.eqState.enable ? 0 : 1)
                                    }
                                }

                                StyledText {
                                    text: qsTr("Master")
                                    font.weight: 500
                                }

                                Item { Layout.fillWidth: true }

                                StyledInputField {
                                    id: masterGainInput

                                    implicitWidth: 60
                                    text: root.eqState.gain.toFixed(1)
                                    validator: DoubleValidator {
                                        bottom: -18; top: 18; decimals: 1
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("gain", Math.max(-18, Math.min(18, v)));
                                    }
                                }

                                StyledText { text: "dB" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.gain

                                    onMoved: {
                                        root.setEqParam("gain", Math.round(value * 10) / 10);
                                        if (!masterGainInput.hasFocus)
                                            masterGainInput.text = root.eqState.gain.toFixed(1);
                                    }
                                }
                            }

                            // ── HP ──────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: hpFreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.HighPass ? Colours.palette.m3primary
                                                                 : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.HighPass ? Colours.palette.m3onPrimary
                                                                     : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("HighPass", root.eqState.HighPass ? 0 : 1)
                                    }
                                }

                                StyledText { text: "HP"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: hpFreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.HPfreq)
                                    validator: IntValidator { bottom: 5; top: 1250 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("HPfreq", Math.max(5, Math.min(1250, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.HPQ.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0; top: 1.4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("HPQ", Math.max(0, Math.min(1.4, v)));
                                    }
                                }

                                StyledText { text: "Q" }
                                Item { Layout.fillWidth: true }
                            }

                            // ── Low Shelf ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: lsFreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.LSsec ? Colours.palette.m3primary
                                                              : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.LSsec ? Colours.palette.m3onPrimary
                                                                  : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("LSsec", root.eqState.LSsec ? 0 : 1)
                                    }
                                }

                                StyledText { text: "LS"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: lsFreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.LSfreq)
                                    validator: IntValidator { bottom: 25; top: 400 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("LSfreq", Math.max(25, Math.min(400, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.LSq.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("LSq", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.LSgain
                                    onMoved: root.setEqParam("LSgain", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.LSgain >= 0 ? "+" : "") + root.eqState.LSgain.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── Band 1 ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: b1FreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.sec1 ? Colours.palette.m3primary
                                                             : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.sec1 ? Colours.palette.m3onPrimary
                                                                 : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("sec1", root.eqState.sec1 ? 0 : 1)
                                    }
                                }

                                StyledText { text: "1"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: b1FreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.freq1)
                                    validator: IntValidator { bottom: 20; top: 2000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("freq1", Math.max(20, Math.min(2000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.q1.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("q1", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.gain1
                                    onMoved: root.setEqParam("gain1", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.gain1 >= 0 ? "+" : "") + root.eqState.gain1.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── Band 2 ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: b2FreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.sec2 ? Colours.palette.m3primary
                                                             : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.sec2 ? Colours.palette.m3onPrimary
                                                                 : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("sec2", root.eqState.sec2 ? 0 : 1)
                                    }
                                }

                                StyledText { text: "2"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: b2FreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.freq2)
                                    validator: IntValidator { bottom: 40; top: 4000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("freq2", Math.max(40, Math.min(4000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.q2.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("q2", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.gain2
                                    onMoved: root.setEqParam("gain2", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.gain2 >= 0 ? "+" : "") + root.eqState.gain2.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── Band 3 ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: b3FreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.sec3 ? Colours.palette.m3primary
                                                             : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.sec3 ? Colours.palette.m3onPrimary
                                                                 : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("sec3", root.eqState.sec3 ? 0 : 1)
                                    }
                                }

                                StyledText { text: "3"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: b3FreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.freq3)
                                    validator: IntValidator { bottom: 100; top: 10000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("freq3", Math.max(100, Math.min(10000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.q3.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("q3", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.gain3
                                    onMoved: root.setEqParam("gain3", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.gain3 >= 0 ? "+" : "") + root.eqState.gain3.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── Band 4 ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: b4FreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.sec4 ? Colours.palette.m3primary
                                                             : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.sec4 ? Colours.palette.m3onPrimary
                                                                 : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("sec4", root.eqState.sec4 ? 0 : 1)
                                    }
                                }

                                StyledText { text: "4"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: b4FreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.freq4)
                                    validator: IntValidator { bottom: 200; top: 20000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("freq4", Math.max(200, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.q4.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("q4", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.gain4
                                    onMoved: root.setEqParam("gain4", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.gain4 >= 0 ? "+" : "") + root.eqState.gain4.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── High Shelf ───────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: hsFreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.HSsec ? Colours.palette.m3primary
                                                              : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.HSsec ? Colours.palette.m3onPrimary
                                                                  : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("HSsec", root.eqState.HSsec ? 0 : 1)
                                    }
                                }

                                StyledText { text: "HS"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: hsFreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.HSfreq)
                                    validator: IntValidator { bottom: 1000; top: 16000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("HSfreq", Math.max(1000, Math.min(16000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.HSq.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0.0625; top: 4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("HSq", Math.max(0.0625, Math.min(4, v)));
                                    }
                                }

                                StyledText { text: "Q" }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -18; to: 18
                                    value: root.eqState.HSgain
                                    onMoved: root.setEqParam("HSgain", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: (root.eqState.HSgain >= 0 ? "+" : "") + root.eqState.HSgain.toFixed(1) + " dB"
                                    Layout.preferredWidth: 58
                                }
                            }

                            // ── LP ──────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: lpFreqInput.implicitHeight
                                    radius: Tokens.rounding.small
                                    color: root.eqState.LowPass ? Colours.palette.m3primary
                                                                : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.eqState.LowPass ? Colours.palette.m3onPrimary
                                                                    : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setEqParam("LowPass", root.eqState.LowPass ? 0 : 1)
                                    }
                                }

                                StyledText { text: "LP"; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignHCenter }

                                StyledInputField {
                                    id: lpFreqInput
                                    implicitWidth: 65
                                    text: Math.round(root.eqState.LPfreq)
                                    validator: IntValidator { bottom: 500; top: 20000 }

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setEqParam("LPfreq", Math.max(500, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }

                                StyledInputField {
                                    implicitWidth: 50
                                    text: root.eqState.LPQ.toFixed(2)
                                    validator: DoubleValidator {
                                        bottom: 0; top: 1.4; decimals: 2
                                        notation: DoubleValidator.StandardNotation
                                    }

                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v))
                                            root.setEqParam("LPQ", Math.max(0, Math.min(1.4, v)));
                                    }
                                }

                                StyledText { text: "Q" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Mic Gate")
                        description: qsTr("LSP Gate Stereo — controls when the mic signal passes through")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            // ── Threshold ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Threshold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.linToDb(root.gateState.gt)
                                    onMoved: root.setGateParam("gt", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.gateState.gt).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Zone ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Zone"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0.001; to: 1.0
                                    value: root.gateState.gz
                                    onMoved: root.setGateParam("gz", Math.round(value * 1000) / 1000)
                                }

                                StyledText {
                                    text: root.gateState.gz.toFixed(3)
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Attack ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Attack"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 2000
                                    value: root.gateState.at
                                    onMoved: root.setGateParam("at", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.gateState.at.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Hold ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Hold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 1000
                                    value: root.gateState.hold
                                    onMoved: root.setGateParam("hold", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.gateState.hold.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Release ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Release"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 5000
                                    value: root.gateState.rt
                                    onMoved: root.setGateParam("rt", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.gateState.rt.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Floor ────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Floor"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -80; to: 0
                                    value: root.linToDb(root.gateState.gr)
                                    onMoved: root.setGateParam("gr", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.gateState.gr).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Makeup ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Makeup"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -20; to: 20
                                    value: root.linToDb(root.gateState.mk)
                                    onMoved: root.setGateParam("mk", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.gateState.mk) >= 0 ? "+" : "") + root.linToDb(root.gateState.mk).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Hysteresis toggle ────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: hystLabel.implicitHeight + Tokens.padding.small * 2
                                    radius: Tokens.rounding.small
                                    color: root.gateState.gh ? Colours.palette.m3primary
                                                             : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "done"
                                        color: root.gateState.gh ? Colours.palette.m3onPrimary
                                                                 : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setGateParam("gh", root.gateState.gh ? 0 : 1)
                                    }
                                }

                                StyledText {
                                    id: hystLabel
                                    text: qsTr("Hysteresis")
                                    font.weight: 500
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── Hyst. Threshold ──────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.gateState.gh ? 1.0 : 0.4

                                StyledText { text: qsTr("Hyst. Thr."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.linToDb(root.gateState.ht)
                                    onMoved: root.setGateParam("ht", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.gateState.ht).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Hyst. Zone ───────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.gateState.gh ? 1.0 : 0.4

                                StyledText { text: qsTr("Hyst. Zone"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0.001; to: 1.0
                                    value: root.gateState.hz
                                    onMoved: root.setGateParam("hz", Math.round(value * 1000) / 1000)
                                }

                                StyledText {
                                    text: root.gateState.hz.toFixed(3)
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Mic Noise Reduction")
                        description: qsTr("RNNoise — neural network based voice noise suppression")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.normal

                            StyledRect {
                                implicitWidth: implicitHeight
                                implicitHeight: nrLabel.implicitHeight + Tokens.padding.small * 2
                                radius: Tokens.rounding.small
                                color: root.nrEnabled ? Colours.palette.m3primary
                                                      : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "done"
                                    color: root.nrEnabled ? Colours.palette.m3onPrimary
                                                          : Colours.palette.m3onSurface
                                }

                                StateLayer {
                                    onClicked: root.setNrEnabled(!root.nrEnabled)
                                }
                            }

                            StyledText {
                                id: nrLabel
                                text: root.nrEnabled ? qsTr("Enabled") : qsTr("Disabled")
                                font.weight: 500
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Mic Compressor")
                        description: qsTr("LSP Compressor Stereo — dynamics control for mic signal")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            // ── Enable + Mode ────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: compModeDownLabel.implicitHeight + Tokens.padding.small * 2
                                    radius: Tokens.rounding.small
                                    color: root.compState.enabled ? Colours.palette.m3primary
                                                                  : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "power_settings_new"
                                        fill: root.compState.enabled ? 1 : 0
                                        color: root.compState.enabled ? Colours.palette.m3onPrimary
                                                                      : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setCompParam("enabled", root.compState.enabled ? 0 : 1)
                                    }
                                }

                                StyledText { text: qsTr("Mode"); font.weight: 500 }

                                Item { Layout.fillWidth: true }

                                StyledRect {
                                    implicitWidth: compModeDownLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compModeDownLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.cm === 0 ? Colours.palette.m3primary
                                                                   : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compModeDownLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Down")
                                        color: root.compState.cm === 0 ? Colours.palette.m3onPrimary
                                                                       : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("cm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compModeUpLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compModeUpLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.cm === 1 ? Colours.palette.m3primary
                                                                   : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compModeUpLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Up")
                                        color: root.compState.cm === 1 ? Colours.palette.m3onPrimary
                                                                       : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("cm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compModeBootLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compModeBootLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.cm === 2 ? Colours.palette.m3primary
                                                                   : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compModeBootLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Boot")
                                        color: root.compState.cm === 2 ? Colours.palette.m3onPrimary
                                                                       : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("cm", 2) }
                                }
                            }

                            // ── Threshold ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Threshold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.linToDb(root.compState.al)
                                    onMoved: root.setCompParam("al", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.compState.al).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Attack ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Attack"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 2000
                                    value: root.compState.at
                                    onMoved: root.setCompParam("at", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.at.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Hold ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Hold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 1000
                                    value: root.compState.hold
                                    onMoved: root.setCompParam("hold", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.hold.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Release ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Release"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 5000
                                    value: root.compState.rt
                                    onMoved: root.setCompParam("rt", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.rt.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Release threshold ─────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Rel. Thr."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.compState.rrl < 0.001 ? -60 : root.linToDb(root.compState.rrl)
                                    onMoved: {
                                        const db = Math.round(value * 10) / 10;
                                        root.setCompParam("rrl", db <= -59.9 ? 0.0 : root.dbToLin(db));
                                    }
                                }

                                StyledText {
                                    text: root.compState.rrl < 0.001 ? qsTr("Auto")
                                                                      : root.linToDb(root.compState.rrl).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Ratio ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Ratio"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 1; to: 100
                                    value: root.compState.cr
                                    onMoved: root.setCompParam("cr", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.cr.toFixed(1) + ":1"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Knee ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Knee"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0.0631; to: 1.0
                                    value: root.compState.kn
                                    onMoved: root.setCompParam("kn", Math.round(value * 1000) / 1000)
                                }

                                StyledText {
                                    text: root.compState.kn.toFixed(3)
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Makeup ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Makeup"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(root.compState.mk)
                                    onMoved: root.setCompParam("mk", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.compState.mk) >= 0 ? "+" : "") + root.linToDb(root.compState.mk).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Input gain ───────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Input gain"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -20; to: 20
                                    value: root.linToDb(root.compState.g_in)
                                    onMoved: root.setCompParam("g_in", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.compState.g_in) >= 0 ? "+" : "") + root.linToDb(root.compState.g_in).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Output gain ──────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Output gain"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -20; to: 20
                                    value: root.linToDb(root.compState.g_out)
                                    onMoved: root.setCompParam("g_out", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.compState.g_out) >= 0 ? "+" : "") + root.linToDb(root.compState.g_out).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Dry/Wet ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Dry/Wet"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 100
                                    value: root.compState.cdw
                                    onMoved: root.setCompParam("cdw", Math.round(value))
                                }

                                StyledText {
                                    text: root.compState.cdw.toFixed(0) + " %"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Type ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Type"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: compSctFfwdLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSctFfwdLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.sct === 0 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSctFfwdLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Feed-fwd")
                                        color: root.compState.sct === 0 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("sct", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compSctFbkLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSctFbkLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.sct === 1 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSctFbkLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Feed-bk")
                                        color: root.compState.sct === 1 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("sct", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compSctLinkLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSctLinkLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.sct === 2 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSctLinkLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Link")
                                        color: root.compState.sct === 2 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("sct", 2) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Mode ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Mode"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: compScmPeakLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScmPeakLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scm === 0 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScmPeakLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Peak")
                                        color: root.compState.scm === 0 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compScmRmsLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScmRmsLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scm === 1 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScmRmsLabel
                                        anchors.centerIn: parent
                                        text: qsTr("RMS")
                                        color: root.compState.scm === 1 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compScmLpfLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScmLpfLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scm === 2 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScmLpfLabel
                                        anchors.centerIn: parent
                                        text: qsTr("LPF")
                                        color: root.compState.scm === 2 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: compScmSmaLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScmSmaLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scm === 3 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScmSmaLabel
                                        anchors.centerIn: parent
                                        text: qsTr("SMA")
                                        color: root.compState.scm === 3 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scm", 3) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Source ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Source"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: compScsMidLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsMidLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 0 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsMidLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Mid")
                                        color: root.compState.scs === 0 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compScsSideLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsSideLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 1 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsSideLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Side")
                                        color: root.compState.scs === 1 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compScsLLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsLLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 2 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsLLabel
                                        anchors.centerIn: parent
                                        text: qsTr("L")
                                        color: root.compState.scs === 2 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 2) }
                                }

                                StyledRect {
                                    implicitWidth: compScsRLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsRLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 3 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsRLabel
                                        anchors.centerIn: parent
                                        text: qsTr("R")
                                        color: root.compState.scs === 3 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 3) }
                                }

                                StyledRect {
                                    implicitWidth: compScsMinLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsMinLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 4 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsMinLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Min")
                                        color: root.compState.scs === 4 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 4) }
                                }

                                StyledRect {
                                    implicitWidth: compScsMaxLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compScsMaxLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.scs === 5 ? Colours.palette.m3primary
                                                                    : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compScsMaxLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Max")
                                        color: root.compState.scs === 5 ? Colours.palette.m3onPrimary
                                                                        : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("scs", 5) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Lookahead ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Lookahead"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 20
                                    value: root.compState.sla
                                    onMoved: root.setCompParam("sla", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.sla.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Reactivity ────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Reactivity"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 250
                                    value: root.compState.scr
                                    onMoved: root.setCompParam("scr", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.compState.scr.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Preamp ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Preamp"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(Math.max(root.compState.scp, 0.001))
                                    onMoved: root.setCompParam("scp", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(Math.max(root.compState.scp, 0.001)) >= 0 ? "+" : "")
                                          + root.linToDb(Math.max(root.compState.scp, 0.001)).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC HP filter ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC HP"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: compShpmOffLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compShpmOffLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.shpm === 0 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compShpmOffLabel
                                        anchors.centerIn: parent
                                        text: qsTr("off")
                                        color: root.compState.shpm === 0 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("shpm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compShpm12Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compShpm12Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.shpm === 1 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compShpm12Label
                                        anchors.centerIn: parent
                                        text: "12"
                                        color: root.compState.shpm === 1 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("shpm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compShpm24Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compShpm24Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.shpm === 2 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compShpm24Label
                                        anchors.centerIn: parent
                                        text: "24"
                                        color: root.compState.shpm === 2 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("shpm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: compShpm36Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compShpm36Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.shpm === 3 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compShpm36Label
                                        anchors.centerIn: parent
                                        text: "36"
                                        color: root.compState.shpm === 3 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("shpm", 3) }
                                }

                                StyledInputField {
                                    id: compShpfInput
                                    implicitWidth: 65
                                    text: Math.round(root.compState.shpf)
                                    validator: IntValidator { bottom: 10; top: 20000 }
                                    enabled: root.compState.shpm > 0

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setCompParam("shpf", Math.max(10, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }
                                Item { Layout.fillWidth: true }
                            }

                            // ── SC LP filter ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC LP"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: compSlpmOffLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSlpmOffLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.slpm === 0 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSlpmOffLabel
                                        anchors.centerIn: parent
                                        text: qsTr("off")
                                        color: root.compState.slpm === 0 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("slpm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: compSlpm12Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSlpm12Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.slpm === 1 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSlpm12Label
                                        anchors.centerIn: parent
                                        text: "12"
                                        color: root.compState.slpm === 1 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("slpm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: compSlpm24Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSlpm24Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.slpm === 2 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSlpm24Label
                                        anchors.centerIn: parent
                                        text: "24"
                                        color: root.compState.slpm === 2 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("slpm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: compSlpm36Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: compSlpm36Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.compState.slpm === 3 ? Colours.palette.m3primary
                                                                     : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: compSlpm36Label
                                        anchors.centerIn: parent
                                        text: "36"
                                        color: root.compState.slpm === 3 ? Colours.palette.m3onPrimary
                                                                         : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setCompParam("slpm", 3) }
                                }

                                StyledInputField {
                                    id: compSlpfInput
                                    implicitWidth: 65
                                    text: Math.round(root.compState.slpf)
                                    validator: IntValidator { bottom: 10; top: 20000 }
                                    enabled: root.compState.slpm > 0

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setCompParam("slpf", Math.max(10, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }
                                Item { Layout.fillWidth: true }
                            }

                            // ── Boot: Boost threshold ─────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.compState.cm === 2 ? 1.0 : 0.4

                                StyledText { text: qsTr("Boost Thr."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -120; to: -60
                                    value: root.linToDb(root.compState.bth)
                                    onMoved: root.setCompParam("bth", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.compState.bth).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Boot: Boost amount ────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.compState.cm === 2 ? 1.0 : 0.4

                                StyledText { text: qsTr("Boost Amt."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(root.compState.bsa)
                                    onMoved: root.setCompParam("bsa", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.compState.bsa) >= 0 ? "+" : "") + root.linToDb(root.compState.bsa).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }

                    SectionHeader {
                        title: qsTr("Chat Noise Reduction")
                        description: qsTr("RNNoise — neural network based voice noise suppression")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.normal

                            StyledRect {
                                implicitWidth: implicitHeight
                                implicitHeight: chatNrLabel.implicitHeight + Tokens.padding.small * 2
                                radius: Tokens.rounding.small
                                color: root.chatNrEnabled ? Colours.palette.m3primary
                                                          : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "done"
                                    color: root.chatNrEnabled ? Colours.palette.m3onPrimary
                                                              : Colours.palette.m3onSurface
                                }

                                StateLayer {
                                    onClicked: root.setChatNrEnabled(!root.chatNrEnabled)
                                }
                            }

                            StyledText {
                                id: chatNrLabel
                                text: root.chatNrEnabled ? qsTr("Enabled") : qsTr("Disabled")
                                font.weight: 500
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }

                    SectionHeader {
                        title: qsTr("Chat Compressor")
                        description: qsTr("LSP Compressor Stereo — dynamics control for chat signal")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            // ── Enable + Mode ────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: chatCompModeDownLabel.implicitHeight + Tokens.padding.small * 2
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.enabled ? Colours.palette.m3primary
                                                                      : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "power_settings_new"
                                        fill: root.chatCompState.enabled ? 1 : 0
                                        color: root.chatCompState.enabled ? Colours.palette.m3onPrimary
                                                                          : Colours.palette.m3onSurface
                                    }

                                    StateLayer {
                                        onClicked: root.setChatCompParam("enabled", root.chatCompState.enabled ? 0 : 1)
                                    }
                                }

                                StyledText { text: qsTr("Mode"); font.weight: 500 }

                                Item { Layout.fillWidth: true }

                                StyledRect {
                                    implicitWidth: chatCompModeDownLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompModeDownLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.cm === 0 ? Colours.palette.m3primary
                                                                       : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompModeDownLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Down")
                                        color: root.chatCompState.cm === 0 ? Colours.palette.m3onPrimary
                                                                           : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("cm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompModeUpLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompModeUpLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.cm === 1 ? Colours.palette.m3primary
                                                                       : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompModeUpLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Up")
                                        color: root.chatCompState.cm === 1 ? Colours.palette.m3onPrimary
                                                                           : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("cm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompModeBootLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompModeBootLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.cm === 2 ? Colours.palette.m3primary
                                                                       : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompModeBootLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Boot")
                                        color: root.chatCompState.cm === 2 ? Colours.palette.m3onPrimary
                                                                           : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("cm", 2) }
                                }
                            }

                            // ── Threshold ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Threshold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.linToDb(root.chatCompState.al)
                                    onMoved: root.setChatCompParam("al", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.chatCompState.al).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Attack ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Attack"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 2000
                                    value: root.chatCompState.at
                                    onMoved: root.setChatCompParam("at", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.at.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Hold ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Hold"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 1000
                                    value: root.chatCompState.hold
                                    onMoved: root.setChatCompParam("hold", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.hold.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Release ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Release"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 5000
                                    value: root.chatCompState.rt
                                    onMoved: root.setChatCompParam("rt", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.rt.toFixed(0) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Release threshold ─────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Rel. Thr."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -60; to: 0
                                    value: root.chatCompState.rrl < 0.001 ? -60 : root.linToDb(root.chatCompState.rrl)
                                    onMoved: {
                                        const db = Math.round(value * 10) / 10;
                                        root.setChatCompParam("rrl", db <= -59.9 ? 0.0 : root.dbToLin(db));
                                    }
                                }

                                StyledText {
                                    text: root.chatCompState.rrl < 0.001 ? qsTr("Auto")
                                                                          : root.linToDb(root.chatCompState.rrl).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Ratio ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Ratio"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 1; to: 100
                                    value: root.chatCompState.cr
                                    onMoved: root.setChatCompParam("cr", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.cr.toFixed(1) + ":1"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Knee ─────────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Knee"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0.0631; to: 1.0
                                    value: root.chatCompState.kn
                                    onMoved: root.setChatCompParam("kn", Math.round(value * 1000) / 1000)
                                }

                                StyledText {
                                    text: root.chatCompState.kn.toFixed(3)
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Makeup ───────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Makeup"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(root.chatCompState.mk)
                                    onMoved: root.setChatCompParam("mk", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.chatCompState.mk) >= 0 ? "+" : "") + root.linToDb(root.chatCompState.mk).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Input gain ───────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Input gain"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -20; to: 20
                                    value: root.linToDb(root.chatCompState.g_in)
                                    onMoved: root.setChatCompParam("g_in", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.chatCompState.g_in) >= 0 ? "+" : "") + root.linToDb(root.chatCompState.g_in).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Output gain ──────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Output gain"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -20; to: 20
                                    value: root.linToDb(root.chatCompState.g_out)
                                    onMoved: root.setChatCompParam("g_out", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.chatCompState.g_out) >= 0 ? "+" : "") + root.linToDb(root.chatCompState.g_out).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Dry/Wet ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("Dry/Wet"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 100
                                    value: root.chatCompState.cdw
                                    onMoved: root.setChatCompParam("cdw", Math.round(value))
                                }

                                StyledText {
                                    text: root.chatCompState.cdw.toFixed(0) + " %"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Type ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Type"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: chatCompSctFfwdLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSctFfwdLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.sct === 0 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSctFfwdLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Feed-fwd")
                                        color: root.chatCompState.sct === 0 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("sct", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompSctFbkLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSctFbkLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.sct === 1 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSctFbkLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Feed-bk")
                                        color: root.chatCompState.sct === 1 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("sct", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompSctLinkLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSctLinkLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.sct === 2 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSctLinkLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Link")
                                        color: root.chatCompState.sct === 2 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("sct", 2) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Mode ──────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Mode"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: chatCompScmPeakLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScmPeakLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scm === 0 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScmPeakLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Peak")
                                        color: root.chatCompState.scm === 0 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScmRmsLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScmRmsLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scm === 1 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScmRmsLabel
                                        anchors.centerIn: parent
                                        text: qsTr("RMS")
                                        color: root.chatCompState.scm === 1 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScmLpfLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScmLpfLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scm === 2 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScmLpfLabel
                                        anchors.centerIn: parent
                                        text: qsTr("LPF")
                                        color: root.chatCompState.scm === 2 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScmSmaLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScmSmaLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scm === 3 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScmSmaLabel
                                        anchors.centerIn: parent
                                        text: qsTr("SMA")
                                        color: root.chatCompState.scm === 3 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scm", 3) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Source ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Source"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: chatCompScsMidLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsMidLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 0 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsMidLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Mid")
                                        color: root.chatCompState.scs === 0 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScsSideLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsSideLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 1 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsSideLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Side")
                                        color: root.chatCompState.scs === 1 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScsLLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsLLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 2 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsLLabel
                                        anchors.centerIn: parent
                                        text: qsTr("L")
                                        color: root.chatCompState.scs === 2 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 2) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScsRLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsRLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 3 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsRLabel
                                        anchors.centerIn: parent
                                        text: qsTr("R")
                                        color: root.chatCompState.scs === 3 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 3) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScsMinLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsMinLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 4 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsMinLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Min")
                                        color: root.chatCompState.scs === 4 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 4) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompScsMaxLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompScsMaxLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.scs === 5 ? Colours.palette.m3primary
                                                                        : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompScsMaxLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Max")
                                        color: root.chatCompState.scs === 5 ? Colours.palette.m3onPrimary
                                                                            : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("scs", 5) }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // ── SC Lookahead ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Lookahead"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 20
                                    value: root.chatCompState.sla
                                    onMoved: root.setChatCompParam("sla", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.sla.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Reactivity ────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Reactivity"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: 0; to: 250
                                    value: root.chatCompState.scr
                                    onMoved: root.setChatCompParam("scr", Math.round(value * 10) / 10)
                                }

                                StyledText {
                                    text: root.chatCompState.scr.toFixed(1) + " ms"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC Preamp ────────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC Preamp"); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(Math.max(root.chatCompState.scp, 0.001))
                                    onMoved: root.setChatCompParam("scp", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(Math.max(root.chatCompState.scp, 0.001)) >= 0 ? "+" : "")
                                          + root.linToDb(Math.max(root.chatCompState.scp, 0.001)).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── SC HP filter ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC HP"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: chatCompShpmOffLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompShpmOffLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.shpm === 0 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompShpmOffLabel
                                        anchors.centerIn: parent
                                        text: qsTr("off")
                                        color: root.chatCompState.shpm === 0 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("shpm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompShpm12Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompShpm12Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.shpm === 1 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompShpm12Label
                                        anchors.centerIn: parent
                                        text: "12"
                                        color: root.chatCompState.shpm === 1 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("shpm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompShpm24Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompShpm24Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.shpm === 2 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompShpm24Label
                                        anchors.centerIn: parent
                                        text: "24"
                                        color: root.chatCompState.shpm === 2 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("shpm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompShpm36Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompShpm36Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.shpm === 3 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompShpm36Label
                                        anchors.centerIn: parent
                                        text: "36"
                                        color: root.chatCompState.shpm === 3 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("shpm", 3) }
                                }

                                StyledInputField {
                                    id: chatCompShpfInput
                                    implicitWidth: 65
                                    text: Math.round(root.chatCompState.shpf)
                                    validator: IntValidator { bottom: 10; top: 20000 }
                                    enabled: root.chatCompState.shpm > 0

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setChatCompParam("shpf", Math.max(10, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }
                                Item { Layout.fillWidth: true }
                            }

                            // ── SC LP filter ─────────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal

                                StyledText { text: qsTr("SC LP"); Layout.preferredWidth: 90 }

                                StyledRect {
                                    implicitWidth: chatCompSlpmOffLabel.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSlpmOffLabel.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.slpm === 0 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSlpmOffLabel
                                        anchors.centerIn: parent
                                        text: qsTr("off")
                                        color: root.chatCompState.slpm === 0 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("slpm", 0) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompSlpm12Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSlpm12Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.slpm === 1 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSlpm12Label
                                        anchors.centerIn: parent
                                        text: "12"
                                        color: root.chatCompState.slpm === 1 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("slpm", 1) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompSlpm24Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSlpm24Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.slpm === 2 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSlpm24Label
                                        anchors.centerIn: parent
                                        text: "24"
                                        color: root.chatCompState.slpm === 2 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("slpm", 2) }
                                }

                                StyledRect {
                                    implicitWidth: chatCompSlpm36Label.implicitWidth + Tokens.padding.normal
                                    implicitHeight: chatCompSlpm36Label.implicitHeight + Tokens.padding.small
                                    radius: Tokens.rounding.small
                                    color: root.chatCompState.slpm === 3 ? Colours.palette.m3primary
                                                                         : Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                    StyledText {
                                        id: chatCompSlpm36Label
                                        anchors.centerIn: parent
                                        text: "36"
                                        color: root.chatCompState.slpm === 3 ? Colours.palette.m3onPrimary
                                                                             : Colours.palette.m3onSurface
                                    }

                                    StateLayer { onClicked: root.setChatCompParam("slpm", 3) }
                                }

                                StyledInputField {
                                    id: chatCompSlpfInput
                                    implicitWidth: 65
                                    text: Math.round(root.chatCompState.slpf)
                                    validator: IntValidator { bottom: 10; top: 20000 }
                                    enabled: root.chatCompState.slpm > 0

                                    onEditingFinished: {
                                        const v = parseInt(text);
                                        if (!isNaN(v))
                                            root.setChatCompParam("slpf", Math.max(10, Math.min(20000, v)));
                                    }
                                }

                                StyledText { text: "Hz" }
                                Item { Layout.fillWidth: true }
                            }

                            // ── Boot: Boost threshold ─────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.chatCompState.cm === 2 ? 1.0 : 0.4

                                StyledText { text: qsTr("Boost Thr."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -120; to: -60
                                    value: root.linToDb(root.chatCompState.bth)
                                    onMoved: root.setChatCompParam("bth", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: root.linToDb(root.chatCompState.bth).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // ── Boot: Boost amount ────────────────────────────────────────
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.normal
                                opacity: root.chatCompState.cm === 2 ? 1.0 : 0.4

                                StyledText { text: qsTr("Boost Amt."); Layout.preferredWidth: 90 }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: Tokens.padding.normal * 3
                                    from: -40; to: 40
                                    value: root.linToDb(root.chatCompState.bsa)
                                    onMoved: root.setChatCompParam("bsa", root.dbToLin(Math.round(value * 10) / 10))
                                }

                                StyledText {
                                    text: (root.linToDb(root.chatCompState.bsa) >= 0 ? "+" : "") + root.linToDb(root.chatCompState.bsa).toFixed(1) + " dB"
                                    Layout.preferredWidth: 72
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
