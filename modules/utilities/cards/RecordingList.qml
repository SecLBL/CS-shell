pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Models
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property var props
    required property ScreenState screenState

    spacing: 0

    WrapperMouseArea {
        Layout.fillWidth: true

        cursorShape: Qt.PointingHandCursor
        onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded

        RowLayout {
            spacing: Tokens.spacing.medium

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: "list"
                fontStyle: Tokens.font.icon.large
            }

            // Recordings or replay clips
            Repeater {
                model: [["recordings", Tr.tr("Recordings")], ["clips", qsTr("Clips")]]

                TextButton {
                    required property var modelData
                    readonly property bool current: (root.props.recordingListTab || "recordings") === modelData[0]

                    Layout.alignment: Qt.AlignVCenter
                    text: modelData[1]
                    type: current ? TextButton.Tonal : TextButton.Text
                    onClicked: root.props.recordingListTab = modelData[0]
                }
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                icon: root.props.recordingListExpanded ? "unfold_less" : "unfold_more"
                type: IconButton.Text
                label.animate: true
                onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded
            }
        }
    }

    StyledListView {
        id: list

        model: FileSystemModel {
            readonly property bool clips: root.props.recordingListTab === "clips"

            path: clips ? Replay.clipsDir : Replay.recordingsDir
            nameFilters: clips ? ["clip_*"] : ["recording_*"]
            sortReverse: true
        }

        Layout.fillWidth: true
        Layout.rightMargin: -Tokens.spacing.small
        implicitHeight: (Tokens.font.body.large.pointSize + Tokens.padding.small) * (root.props.recordingListExpanded ? 10 : 3)
        clip: true

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: list
        }

        delegate: RowLayout {
            id: recording

            required property FileSystemEntry modelData
            property string baseName

            anchors.left: list.contentItem.left
            anchors.right: list.contentItem.right
            anchors.rightMargin: Tokens.spacing.small
            spacing: Tokens.spacing.extraSmall

            Component.onCompleted: baseName = modelData.baseName

            StyledText {
                Layout.fillWidth: true
                Layout.rightMargin: Tokens.spacing.extraSmall
                text: {
                    const time = recording.baseName;
                    const matches = time.match(/^(recording|clip)_(\d{4})(\d{2})(\d{2})_(\d{2})-(\d{2})-(\d{2})(?:_(.+))?/);
                    if (!matches)
                        return time;
                    const date = new Date(...matches.slice(2, 8));
                    date.setMonth(date.getMonth() - 1); // Woe (months start from 0)
                    const when = Qt.formatDateTime(date, Qt.locale(), Locale.ShortFormat);
                    if (matches[1] === "clip")
                        return matches[8] ? qsTr("%1 · %2").arg(matches[8]).arg(when) : qsTr("Clip at %1").arg(when);
                    return Tr.tr("Recording at %1").arg(Qt.formatDateTime(date, Qt.locale()));
                }
                color: Colours.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }

            IconButton {
                icon: "play_arrow"
                type: IconButton.Text
                onClicked: {
                    root.screenState.utilities = false;
                    root.screenState.sidebar = false;
                    Quickshell.execDetached([...GlobalConfig.general.apps.playback, recording.modelData.path]);
                }
            }

            IconButton {
                icon: "folder"
                type: IconButton.Text
                onClicked: {
                    root.screenState.utilities = false;
                    root.screenState.sidebar = false;
                    Quickshell.execDetached([...GlobalConfig.general.apps.explorer, recording.modelData.path]);
                }
            }

            IconButton {
                icon: "delete_forever"
                type: IconButton.Text
                label.color: Colours.palette.m3error
                stateLayer.color: Colours.palette.m3error
                onClicked: root.props.recordingConfirmDelete = recording.modelData.path
            }
        }

        add: Transition {
            Anim {
                type: Anim.DefaultEffects
                property: "opacity"
                from: 0
                to: 1
            }
        }

        remove: Transition {
            Anim {
                type: Anim.DefaultEffects
                property: "opacity"
                to: 0
            }
        }

        displaced: Transition {
            Anim {
                type: Anim.DefaultEffects
                property: "opacity"
                to: 1
            }
            Anim {
                property: "y"
            }
        }

        Loader {
            asynchronous: true
            anchors.centerIn: parent

            opacity: list.count === 0 ? 1 : 0
            active: opacity > 0

            sourceComponent: ColumnLayout {
                spacing: Tokens.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "scan_delete"
                    color: Colours.palette.m3outline
                    fontStyle: Tokens.font.icon.extraLarge

                    opacity: root.props.recordingListExpanded ? 1 : 0
                    scale: root.props.recordingListExpanded ? 1 : 0
                    Layout.preferredHeight: root.props.recordingListExpanded ? implicitHeight : 0

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }

                    Behavior on scale {
                        Anim {}
                    }

                    Behavior on Layout.preferredHeight {
                        Anim {}
                    }
                }

                RowLayout {
                    spacing: Tokens.spacing.medium

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "scan_delete"
                        color: Colours.palette.m3outline

                        opacity: !root.props.recordingListExpanded ? 1 : 0
                        scale: !root.props.recordingListExpanded ? 1 : 0
                        Layout.preferredWidth: !root.props.recordingListExpanded ? implicitWidth : 0

                        Behavior on opacity {
                            Anim {
                                type: Anim.DefaultEffects
                            }
                        }

                        Behavior on scale {
                            Anim {}
                        }

                        Behavior on Layout.preferredWidth {
                            Anim {}
                        }
                    }

                    StyledText {
                        text: root.props.recordingListTab === "clips" ? qsTr("No clips found") : Tr.tr("No recordings found")
                        color: Colours.palette.m3outline
                    }
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }
        }

        Behavior on implicitHeight {
            Anim {}
        }
    }
}
