pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Components
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.components.misc
import qs.services

StyledRect {
    id: root

    required property var props
    required property ScreenState screenState
    readonly property real nonAnimHeight: btnLayout.implicitHeight + replayLayout.implicitHeight + listOrControls.implicitHeight + layout.spacing * 2 + layout.anchors.margins * 2

    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer

    Ref {
        service: Recorder
    }

    Ref {
        service: Replay
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        RowLayout {
            id: btnLayout

            spacing: Tokens.spacing.medium

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: {
                    const h = icon.implicitHeight + Tokens.padding.small * 2;
                    return h - (h % 2);
                }

                radius: Tokens.rounding.full
                color: Recorder.running ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 1
                    text: "screen_record"
                    color: Recorder.running ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    fontStyle: Tokens.font.icon.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: Tr.tr("Screen recorder")
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Recorder.paused ? Tr.trCtx("Paused", "recorder state") : Recorder.running ? Tr.trCtx("Running...", "recorder state") : Tr.trCtx("Ready", "recorder state")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                    animate: true
                }
            }

            SplitButton {
                disabled: Recorder.running

                active: menuItems.find(m => root.props.recordingMode === m.icon + m.text) ?? menuItems[0]
                menu.onItemSelected: item => root.props.recordingMode = item.icon + item.text

                menuItems: [
                    MenuItem {
                        icon: "fullscreen"
                        text: Tr.tr("Record fullscreen")
                        activeText: Tr.trCtx("Fullscreen", "recording mode")
                        onClicked: Recorder.start()
                    },
                    MenuItem {
                        icon: "screenshot_region"
                        text: Tr.tr("Record region")
                        activeText: Tr.trCtx("Region", "recording mode")
                        onClicked: Recorder.start(["-r"])
                    },
                    MenuItem {
                        icon: "select_to_speak"
                        text: Tr.tr("Record fullscreen with sound")
                        activeText: Tr.trCtx("Fullscreen", "recording mode")
                        onClicked: Recorder.start(["-s"])
                    },
                    MenuItem {
                        icon: "volume_up"
                        text: Tr.tr("Record region with sound")
                        activeText: Tr.trCtx("Region", "recording mode")
                        onClicked: Recorder.start(["-sr"])
                    }
                ]
            }
        }

        // Replay buffer: start when off; save (remembered length) and stop when running
        RowLayout {
            id: replayLayout

            spacing: Tokens.spacing.medium

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: {
                    const h = replayIcon.implicitHeight + Tokens.padding.small * 2;
                    return h - (h % 2);
                }

                radius: Tokens.rounding.full
                color: Replay.running ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: replayIcon

                    anchors.centerIn: parent
                    text: "replay"
                    color: Replay.running ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    fontStyle: Tokens.font.icon.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Replay buffer")
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Replay.running ? qsTr("%1 · %2 MB").arg(Replay.formatDuration(Replay.length)).arg(Math.round(Replay.rssMb)) : qsTr("Off")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                    animate: true
                }
            }

            TextButton {
                visible: !Replay.running
                text: qsTr("Start")
                type: TextButton.Tonal
                onClicked: Replay.start()
            }

            SplitButton {
                visible: Replay.running
                type: SplitButton.Tonal

                active: menuItems.find(m => m.value === root.props.replaySaveLength) ?? menuItems[0]
                menu.onItemSelected: item => root.props.replaySaveLength = item.value

                menuItems: saveItems.instances

                Variants {
                    id: saveItems

                    model: [0, ...[10, 30, 60, 300].filter(s => s < Replay.length)]

                    MenuItem {
                        required property int modelData

                        icon: "save"
                        value: modelData
                        text: modelData ? qsTr("Save last %1").arg(Replay.formatDuration(modelData)) : qsTr("Save everything")
                        activeText: modelData ? Replay.formatDuration(modelData) : qsTr("Save")
                        onClicked: Replay.save(modelData)
                    }
                }
            }

            IconButton {
                visible: Replay.running
                icon: "stop"
                type: IconButton.Text
                label.color: Colours.palette.m3error
                stateLayer.color: Colours.palette.m3error
                onClicked: Replay.stop()
            }
        }

        Loader {
            id: listOrControls

            property bool running: Recorder.running

            asynchronous: true
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            sourceComponent: running ? recordingControls : recordingList
            clip: Layout.preferredHeight < implicitHeight

            Behavior on Layout.preferredHeight {
                id: locHeightAnim

                enabled: false

                Anim {}
            }

            Behavior on running {
                SequentialAnimation {
                    Anim {
                        target: listOrControls
                        property: "opacity"
                        to: 0
                        type: Anim.DefaultEffects
                    }
                    PropertyAction {
                        target: locHeightAnim
                        property: "enabled"
                        value: true
                    }
                    PropertyAction {}
                    ParallelAnimation {
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 100
                            }
                            PropertyAction {
                                target: locHeightAnim
                                property: "enabled"
                                value: false
                            }
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 1
                            type: Anim.SlowEffects
                        }
                    }
                }
            }
        }
    }

    Component {
        id: recordingList

        RecordingList {
            props: root.props
            screenState: root.screenState
        }
    }

    Component {
        id: recordingControls

        RowLayout {
            spacing: Tokens.spacing.medium

            StyledRect {
                radius: Tokens.rounding.full
                color: Recorder.paused ? Colours.palette.m3tertiary : Colours.palette.m3error

                implicitWidth: recText.implicitWidth + Tokens.padding.medium * 2
                implicitHeight: recText.implicitHeight + Tokens.padding.large

                StyledText {
                    id: recText

                    anchors.centerIn: parent
                    animate: true
                    text: Recorder.paused ? Tr.trCtx("PAUSED", "recording status") : Tr.trCtx("REC", "recording status")
                    color: Recorder.paused ? Colours.palette.m3onTertiary : Colours.palette.m3onError
                    font: Tokens.font.mono.small
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                SequentialAnimation on opacity {
                    running: !Recorder.paused
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    Anim {
                        from: 1
                        to: 0
                        duration: Tokens.anim.durations.large
                        easing: Tokens.anim.emphasizedAccel
                    }
                    Anim {
                        from: 0
                        to: 1
                        duration: Tokens.anim.durations.extraLarge
                        easing: Tokens.anim.emphasizedDecel
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: {
                    const elapsed = Recorder.elapsed;

                    const hours = Math.floor(elapsed / 3600);
                    const mins = Math.floor((elapsed % 3600) / 60);
                    const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");

                    let time;
                    if (hours > 0)
                        time = `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
                    else
                        time = `${mins}:${secs}`;

                    // TRANSLATORS: %1 = elapsed recording duration, e.g. 01:23
                    return Tr.tr("Recording for %1").arg(time);
                }
                font: Tokens.font.body.medium
                elide: Text.ElideMiddle
            }

            ButtonRow {
                spacing: Tokens.spacing.extraSmall

                IconButton {
                    shapeMorph: true
                    isRound: true
                    label.animate: true
                    icon: Recorder.paused ? "play_arrow" : "pause"
                    isToggle: true
                    checked: Recorder.paused
                    type: IconButton.Tonal
                    font: Tokens.font.icon.medium
                    onClicked: {
                        Recorder.togglePause();
                        internalChecked = Recorder.paused;
                    }

                    implicitWidth: {
                        // Ensure even size so icon is centered properly
                        const h = label.implicitHeight + Tokens.padding.large * 2;
                        if (h % 2 !== 0)
                            return h + 1;
                        return h;
                    }
                }

                IconButton {
                    shapeMorph: true
                    isRound: true
                    icon: "stop"
                    inactiveColour: Colours.palette.m3error
                    inactiveOnColour: Colours.palette.m3onError
                    font: Tokens.font.icon.medium
                    onClicked: Recorder.stop()

                    implicitWidth: {
                        // Ensure even size so icon is centered properly
                        const h = label.implicitHeight + Tokens.padding.large * 2;
                        if (h % 2 !== 0)
                            return h + 1;
                        return h;
                    }
                }
            }
        }
    }
}
