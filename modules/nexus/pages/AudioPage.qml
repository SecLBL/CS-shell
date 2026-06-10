pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Audio")

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
            Layout.fillWidth: true
            first: true
            icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            label: qsTr("Volume")
            valueLabel: Math.round(value * 100) + "%"
            value: Audio.volume
            enabled: !Audio.muted
            onMoved: v => Audio.setVolume(v)
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Muted")
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
            Layout.fillWidth: true
            first: true
            icon: Icons.getVolumeIcon(Audio.chatVolume, Audio.chatMuted)
            label: qsTr("Volume")
            valueLabel: Math.round(value * 100) + "%"
            value: Audio.chatVolume
            enabled: !Audio.chatMuted
            onMoved: v => Audio.setChatVolume(v)
        }

        ToggleRow {
            Layout.fillWidth: true
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
            valueLabel: Math.round(value * 100) + "%"
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
        ConnectedRect {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            implicitHeight: appLayout.implicitHeight + appLayout.anchors.margins * 2
            first: true

            StateLayer {
                onClicked: root.nState.openSubPage(1)
            }

            RowLayout {
                id: appLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.rightMargin: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                MaterialIcon {
                    text: "tune"
                    font: Tokens.font.icon.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("App volumes")
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Audio.streams.length === 0 ? qsTr("No apps playing audio") : Audio.streams.length === 1 ? qsTr("1 app playing audio") : qsTr("%1 apps playing audio").arg(Audio.streams.length)
                        color: Colours.palette.m3outline
                        font: Tokens.font.label.small
                        elide: Text.ElideRight
                        animate: true
                    }
                }

                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.icon.medium
                }
            }
        }

        // Plugin chains (EQ, gate, compressors, noise reduction)
        ConnectedRect {
            Layout.fillWidth: true
            implicitHeight: processingLayout.implicitHeight + processingLayout.anchors.margins * 2
            last: true

            StateLayer {
                onClicked: root.nState.openSubPage(2)
            }

            RowLayout {
                id: processingLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.rightMargin: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                MaterialIcon {
                    text: "equalizer"
                    font: Tokens.font.icon.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Audio processing")
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Equalizer, gate, compressors & noise reduction")
                        color: Colours.palette.m3outline
                        font: Tokens.font.label.small
                        elide: Text.ElideRight
                    }
                }

                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.icon.medium
                }
            }
        }
    }
}
