pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("Audio")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // General output (general_chain_out — after EQ, main output bus)
        SectionHeader {
            first: true
            text: qsTr("General output")
        }

        SliderRow {
            first: true
            icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            label: Tr.tr("Volume")
            valueLabel: Strings.percentOne(value)
            value: Audio.volume
            enabled: !Audio.muted
            onMoved: v => Audio.setVolume(v)
        }

        ToggleRow {
            text: Tr.trCtx("Muted", "audio output muted")
            checked: Audio.muted
            onToggled: Audio.setStreamMuted(Audio.generalChainOutNode, checked)
        }

        AudioDeviceList {
            nodes: Audio.sinks
            currentId: Audio.generalOutputDevice?.id ?? -1
            iconName: "speaker"
            placeholderIcon: "speaker"
            placeholderText: qsTr("No output devices")
            onSelected: node => Audio.setGeneralOutput(node)
        }

        // Chat output (chat_chain_out — after noise reduction and compression)
        SectionHeader {
            text: qsTr("Chat output")
        }

        SliderRow {
            first: true
            icon: Icons.getVolumeIcon(Audio.chatVolume, Audio.chatMuted)
            label: qsTr("Volume")
            valueLabel: Strings.percentOne(value)
            value: Audio.chatVolume
            enabled: !Audio.chatMuted
            onMoved: v => Audio.setChatVolume(v)
        }

        ToggleRow {
            text: qsTr("Muted")
            checked: Audio.chatMuted
            onToggled: Audio.setStreamMuted(Audio.chatChainOutNode, checked)
        }

        AudioDeviceList {
            nodes: Audio.sinks
            currentId: Audio.chatOutputDevice?.id ?? -1
            iconName: "headphones"
            placeholderIcon: "headphones"
            placeholderText: qsTr("No output devices")
            onSelected: node => Audio.setChatOutput(node)
        }

        // Mic input (routes the selected device into the mic processing chain)
        SectionHeader {
            text: qsTr("Mic input")
        }

        SliderRow {
            Layout.fillWidth: true
            first: true
            icon: Icons.getMicVolumeIcon(Audio.micVolume, Audio.micMuted)
            label: qsTr("Volume")
            valueLabel: Strings.percentOne(value)
            value: Audio.micVolume
            enabled: !Audio.micMuted
            onMoved: v => Audio.setMicVolume(v)
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Muted")
            checked: Audio.micMuted
            onToggled: Audio.setStreamMuted(Audio.micChainOutNode, checked)
        }

        AudioDeviceList {
            nodes: Audio.sources
            currentId: Audio.micInputDevice?.id ?? -1
            iconName: "mic"
            placeholderIcon: "mic_off"
            placeholderText: qsTr("No input devices")
            onSelected: node => Audio.setMicInput(node)
        }

        // Per-app volumes
        NavRow {
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            first: true

            icon: "tune"
            text: Tr.tr("App volumes")
            subtext: Audio.streams.length === 0 ? Tr.tr("No apps playing audio") : Tr.trN("%n app playing audio", "%n apps playing audio", Audio.streams.length)
            onClicked: root.nState.openSubPage(1)
        }

        // Plugin chains (EQ, gate, compressors, noise reduction)
        NavRow {
            last: true

            icon: "equalizer"
            text: qsTr("Audio processing")
            subtext: qsTr("Equalizer, gate, compressors & noise reduction")
            onClicked: root.nState.openSubPage(2)
        }
    }
}
