pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Services.Mpris
import M3Shapes
import Caelestia.Components
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.components.widgets
import qs.modules.dashboard.media as Media
import qs.services
import qs.utils

Item {
    id: root

    readonly property real reelSize: 170
    readonly property real centerWidth: 160

    x: CassetteState.posX >= 0 ? CassetteState.posX : (parent.width - width) / 2
    y: CassetteState.posY >= 0 ? CassetteState.posY : (parent.height - height) / 2

    implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2
    width: implicitWidth
    height: implicitHeight

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ServiceRef {
        service: Audio.beatTracker
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        blurMax: 15
        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
    }

    StyledRect {
        anchors.fill: parent
        radius: Tokens.rounding.extraLarge
        color: Colours.tPalette.m3surface

        MouseArea {
            id: dragArea

            anchors.fill: parent
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.ArrowCursor
            drag.target: root
            drag.minimumX: 0
            drag.maximumX: (root.parent?.width ?? 0) - root.width
            drag.minimumY: 0
            drag.maximumY: (root.parent?.height ?? 0) - root.height
            onReleased: {
                CassetteState.posX = root.x;
                CassetteState.posY = root.y;
            }
        }
    }

    RowLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        CoverArt {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: root.reelSize
            implicitHeight: root.reelSize
            shape.shape: MaterialShape.Circle
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: root.centerWidth
            Layout.maximumWidth: root.centerWidth
            spacing: Tokens.spacing.small

            Media.LyricList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 150
                lyricFont: Tokens.font.body.small
            }

            StyledSlider {
                Layout.fillWidth: true
                implicitHeight: Tokens.padding.small * 2

                value: Players.active ? Players.active.position / (Players.active.length || 1) : 0
                enabled: Players.active?.canSeek ?? false
                wavy: true
                animateWave: Players.active?.isPlaying ?? false
                waveFrequency: 5
                waveDuration: 2000
                interactionOnMove: false
                onInteraction: value => {
                    const active = Players.active;
                    if (active?.canSeek && active?.positionSupported)
                        active.position = value * active.length;
                }
            }

            ButtonRow {
                Layout.fillWidth: true
                spacing: Tokens.spacing.extraSmall

                IconButton {
                    type: IconButton.Tonal
                    icon: "shuffle"
                    isRound: true
                    shapeMorph: true
                    checked: Players.active?.shuffle ?? false
                    font: Tokens.font.icon.builders.small.scale(0.8).weight(Font.Medium).build()
                    padding: Tokens.padding.extraSmall
                    disabled: !Players.active?.shuffleSupported
                    onClicked: Players.active.shuffle = !Players.active?.shuffle
                    implicitWidth: Math.round(implicitHeight * 0.9)
                }

                IconButton {
                    type: IconButton.Tonal
                    icon: "skip_previous"
                    isRound: true
                    shapeMorph: true
                    font: Tokens.font.icon.small
                    padding: Tokens.padding.extraSmall
                    disabled: !Players.active?.canGoPrevious
                    onClicked: Players.active?.previous()
                }

                IconButton {
                    icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                    isRound: true
                    shapeMorph: true
                    fillWidth: true
                    checked: Players.active?.isPlaying ?? false
                    font: Tokens.font.icon.small
                    padding: Tokens.padding.extraSmall
                    disabled: !Players.active?.canTogglePlaying
                    onClicked: Players.active?.togglePlaying()
                }

                IconButton {
                    type: IconButton.Tonal
                    icon: "skip_next"
                    isRound: true
                    shapeMorph: true
                    font: Tokens.font.icon.small
                    padding: Tokens.padding.extraSmall
                    disabled: !Players.active?.canGoNext
                    onClicked: Players.active?.next()
                }

                IconButton {
                    type: IconButton.Tonal
                    icon: Players.active?.loopState === MprisLoopState.Track ? "repeat_one" : "repeat"
                    isRound: true
                    shapeMorph: true
                    checked: Players.active?.loopState === MprisLoopState.Track || Players.active?.loopState === MprisLoopState.Playlist
                    font: Tokens.font.icon.builders.small.scale(0.8).weight(Font.Medium).build()
                    padding: Tokens.padding.extraSmall
                    disabled: !Players.active?.loopSupported
                    onClicked: {
                        const state = Players.active.loopState;
                        if (state === MprisLoopState.None)
                            Players.active.loopState = MprisLoopState.Track;
                        else if (state === MprisLoopState.Track)
                            Players.active.loopState = MprisLoopState.Playlist;
                        else
                            Players.active.loopState = MprisLoopState.None;
                    }
                    implicitWidth: Math.round(implicitHeight * 0.9)
                }
            }
        }

        Item {
            id: gifReel

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: root.reelSize
            implicitHeight: root.reelSize

            // Slight glow to separate from bg, same as CoverArt
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 1
                shadowColor: Colours.palette.m3outline
                shadowOpacity: 0.3
            }

            StyledClippingRect {
                anchors.fill: parent
                radius: Tokens.rounding.full
                color: Colours.tPalette.m3surfaceContainerHigh

                AnimatedImage {
                    anchors.fill: parent

                    playing: Players.active?.isPlaying ?? false
                    speed: Audio.beatTracker.bpm / Config.general.mediaGifSpeedAdjustment // qmllint disable unresolved-type
                    source: Paths.absolutePath(Config.paths.cassetteGif)
                    asynchronous: true
                    fillMode: AnimatedImage.PreserveAspectCrop
                }
            }
        }
    }

    IconButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Tokens.padding.small

        type: IconButton.Text
        icon: "close"
        font: Tokens.font.icon.small
        onClicked: CassetteState.open = false
    }
}
