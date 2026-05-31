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

Item {
    id: root

    required property Session session

    anchors.fill: parent

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
                        description: qsTr("MixBus — all apps routing to the main output")
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
                }
            }
        }
    }
}
