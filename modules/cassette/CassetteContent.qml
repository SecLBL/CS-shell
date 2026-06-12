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

    x: Math.max(0, Math.min(CassetteState.posX >= 0 ? CassetteState.posX : (parent.width - width) / 2, parent.width - width))
    y: Math.max(0, Math.min(CassetteState.posY >= 0 ? CassetteState.posY : (parent.height - height) / 2, parent.height - height))

    implicitWidth: contentLoader.implicitWidth + Tokens.padding.large * 2
    implicitHeight: contentLoader.implicitHeight + Tokens.padding.large * 2
    width: implicitWidth
    height: implicitHeight

    // Keep the widget on screen when the mode morph grows it after a drag
    // broke the x/y bindings (assign only when needed to preserve them)
    onWidthChanged: {
        const max = (parent?.width ?? width) - width;
        if (x > max)
            x = Math.max(0, max);
    }
    onHeightChanged: {
        const max = (parent?.height ?? height) - height;
        if (y > max)
            y = Math.max(0, max);
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    PlayerWindowMatcher {
        id: matcher
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        blurMax: 15
        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
    }

    StyledClippingRect {
        anchors.fill: parent
        radius: Tokens.rounding.extraLarge
        color: Colours.tPalette.m3surface

        Media.BackgroundShapes {
            anchors.fill: parent

            count: 8
            minSize: 20
            maxSize: 70
        }

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

    Loader {
        id: contentLoader

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        sourceComponent: matcher.videoMode ? videoLayout : cassetteLayout
    }

    Component {
        id: cassetteLayout

        RowLayout {
            spacing: Tokens.spacing.medium

            ServiceRef {
                service: Audio.beatTracker
            }

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

                CassetteControls {
                    Layout.fillWidth: true
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
    }

    Component {
        id: videoLayout

        ColumnLayout {
            spacing: Tokens.spacing.small

            CassetteVideo {
                Layout.fillWidth: true
                client: matcher.toplevel
            }

            CassetteControls {
                Layout.fillWidth: true
                Layout.leftMargin: Tokens.padding.large
                Layout.rightMargin: Tokens.padding.large
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
