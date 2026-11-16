pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.Models
import qs.components
import qs.components.controls
import qs.components.misc
import qs.services
import qs.modules.nexus.common

// Overview: recorder and replay controls, latest clips, settings
PageBase {
    id: root

    readonly property var conf: GlobalConfig.capture

    function profileSummary(p: var): string {
        return [p.resolution ? `${p.resolution}p` : qsTr("Native"), p.fps ? qsTr("%1 fps").arg(p.fps) : qsTr("native fps"), p.bitrateMode === "cbr" ? qsTr("%1 Mbit/s").arg(p.bitrate / 1000) : qsTr("constant quality")].join(" · ");
    }

    title: qsTr("Recording & replay")

    // Non-visual helpers go into properties; PageBase's default property only takes one item
    readonly property Ref replayRef: Ref {
        service: Replay
    }
    readonly property Ref recorderRef: Ref {
        service: Recorder
    }
    readonly property FileSystemModel clipsModel: FileSystemModel {
        id: clips

        path: Replay.clipsDir
        nameFilters: ["clip_*"]
        sortReverse: true
        watchChanges: true
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            ControlTile {
                icon: "screen_record"
                active: Recorder.running
                title: qsTr("Screen recorder")
                status: Recorder.running ? (Recorder.paused ? qsTr("Paused") : qsTr("Recording · %1").arg(Replay.formatDuration(Math.floor(Recorder.elapsed)))) : qsTr("Ready")

                SplitButton {
                    visible: !Recorder.running
                    type: SplitButton.Tonal
                    menuItems: [
                        MenuItem {
                            icon: "fullscreen"
                            text: qsTr("Screen with sound")
                            activeText: qsTr("Screen")
                            onClicked: Recorder.start(["-s"])
                        },
                        MenuItem {
                            icon: "screenshot_region"
                            text: qsTr("Region with sound")
                            activeText: qsTr("Region")
                            onClicked: Recorder.start(["-sr"])
                        },
                        MenuItem {
                            icon: "videocam_off"
                            text: qsTr("Screen without sound")
                            activeText: qsTr("Screen")
                            onClicked: Recorder.start()
                        },
                        MenuItem {
                            icon: "crop_free"
                            text: qsTr("Region without sound")
                            activeText: qsTr("Region")
                            onClicked: Recorder.start(["-r"])
                        }
                    ]
                }

                IconButton {
                    visible: Recorder.running
                    icon: Recorder.paused ? "play_arrow" : "pause"
                    type: IconButton.Tonal
                    onClicked: Recorder.togglePause()
                }

                IconButton {
                    visible: Recorder.running
                    icon: "stop"
                    inactiveColour: Colours.palette.m3error
                    inactiveOnColour: Colours.palette.m3onError
                    onClicked: Recorder.stop()
                }
            }

            ControlTile {
                icon: "replay"
                active: Replay.running
                title: qsTr("Replay buffer")
                status: Replay.running ? qsTr("%1 · %2 MB").arg(Replay.formatDuration(Replay.length)).arg(Math.round(Replay.rssMb)) : qsTr("Off")

                TextButton {
                    visible: !Replay.running
                    text: qsTr("Start")
                    type: TextButton.Tonal
                    onClicked: Replay.start()
                }

                SplitButton {
                    visible: Replay.running
                    type: SplitButton.Tonal
                    menuItems: saveItems.instances

                    Variants {
                        id: saveItems

                        model: [0, ...[10, 30, 60, 300].filter(s => s < Replay.length)]

                        MenuItem {
                            required property int modelData

                            icon: "save"
                            text: modelData ? qsTr("Save last %1").arg(Replay.formatDuration(modelData)) : qsTr("Save everything")
                            activeText: modelData ? Replay.formatDuration(modelData) : qsTr("Save")
                            onClicked: Replay.save(modelData)
                        }
                    }
                }

                IconButton {
                    visible: Replay.running
                    icon: "stop"
                    inactiveColour: Colours.palette.m3error
                    inactiveOnColour: Colours.palette.m3onError
                    onClicked: Replay.stop()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.largeIncreased
            Layout.bottomMargin: Tokens.spacing.small

            SectionHeader {
                Layout.topMargin: 0
                Layout.bottomMargin: 0
                text: qsTr("Latest clips")
            }

            TextButton {
                text: qsTr("Library")
                type: TextButton.Text
                onClicked: root.nState.openSubPage(1)
            }
        }

        MediaGrid {
            id: grid

            visible: clips.entries.length > 0
            files: clips
            limit: grid.columns
        }

        StyledText {
            visible: clips.entries.length === 0
            Layout.leftMargin: Tokens.padding.small
            text: qsTr("No clips yet")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
        }

        SectionHeader {
            text: qsTr("Settings")
        }

        NavRow {
            first: true
            icon: "replay"
            text: qsTr("Replay buffer")
            subtext: `${Replay.formatDuration(root.conf.replay.length)} · ${root.profileSummary(root.conf.replay)}`
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "screen_record"
            text: qsTr("Screen recorder")
            subtext: root.profileSummary(root.conf.record)
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "graphic_eq"
            text: qsTr("Audio tracks")
            subtext: [root.conf.audio.system ? qsTr("System") : "", root.conf.audio.chat && Audio.chatChainOutNode ? qsTr("Chat") : "", root.conf.audio.mic ? qsTr("Mic") : ""].filter(s => s).join(" · ") || qsTr("None")
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            icon: "smart_toy"
            text: qsTr("Automatic start")
            subtext: !root.conf.autostart.enabled ? qsTr("Paused") : [root.conf.autostart.onShellStart ? qsTr("Shell start") : "", root.conf.autostart.onGameMode ? qsTr("Game mode") : "", root.conf.autostart.apps.length ? qsTr("%n app(s)", "", root.conf.autostart.apps.length) : ""].filter(s => s).join(" · ") || qsTr("Off")
            onClicked: root.nState.openSubPage(5)
        }

        NavRow {
            last: true
            icon: "settings"
            text: qsTr("General")
            subtext: `${root.conf.codec === "auto" ? qsTr("Auto codec") : root.conf.codec} · ${root.conf.container.toUpperCase()}`
            onClicked: root.nState.openSubPage(6)
        }
    }

    // Control card: icon, title, live status and its buttons
    component ControlTile: StyledRect {
        id: tile

        required property string icon
        required property string title
        required property string status
        property bool active
        default property alias buttons: buttonRow.data

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: tileLayout.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.extraLarge
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: tileLayout

            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.medium

            RowLayout {
                spacing: Tokens.spacing.medium

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: tileIcon.implicitHeight + Tokens.padding.small * 2
                    radius: Tokens.rounding.full
                    color: tile.active ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                    MaterialIcon {
                        id: tileIcon

                        anchors.centerIn: parent
                        text: tile.icon
                        color: tile.active ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                        fontStyle: Tokens.font.icon.large
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: tile.title
                        font: Tokens.font.body.medium
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: tile.status
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                        animate: true
                    }
                }
            }

            RowLayout {
                id: buttonRow

                Layout.alignment: Qt.AlignRight
                spacing: Tokens.spacing.small
            }
        }
    }
}
