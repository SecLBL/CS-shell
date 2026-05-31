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

    Component.onCompleted: eqLoadProc.running = true

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
                                                function onAudioChanged() {
                                                    if (!streamVolumeInput.hasFocus && modelData?.audio) {
                                                        streamVolumeInput.text = Math.round(modelData.audio.volume * 100).toString();
                                                    }
                                                }

                                                target: modelData
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
                                            function onAudioChanged() {
                                                if (modelData?.audio) {
                                                    value = modelData.audio.volume;
                                                }
                                            }

                                            target: modelData
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
                }
            }
        }
    }
}
