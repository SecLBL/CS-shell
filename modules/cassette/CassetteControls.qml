import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    spacing: Tokens.spacing.small

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
