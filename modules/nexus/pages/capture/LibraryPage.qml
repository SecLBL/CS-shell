pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.Models
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    property bool clips: true
    property int limit: 24
    readonly property string dir: clips ? Replay.clipsDir : Replay.recordingsDir
    readonly property real totalSize: {
        let sum = 0;
        for (let i = 0; i < fsModel.entries.length; i++)
            sum += fsModel.entries[i].size;
        return sum;
    }

    title: qsTr("Library")
    isSubPage: true

    readonly property FileSystemModel filesModel: FileSystemModel {
        id: fsModel

        path: root.dir
        nameFilters: root.clips ? ["clip_*"] : ["recording_*"]
        sortReverse: true
        watchChanges: true
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            Segmented {
                color: Colours.tPalette.m3surfaceContainer
                options: [[true, qsTr("Clips")], [false, qsTr("Recordings")]]
                current: root.clips
                onPicked: v => {
                    root.clips = v;
                    root.limit = 24;
                }
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: qsTr("%1 files · %2").arg(fsModel.entries.length).arg(Replay.formatSize(root.totalSize))
                color: Colours.palette.m3outline
                font: Tokens.font.body.small
            }

            IconButton {
                icon: "folder_open"
                type: IconButton.Text
                onClicked: Quickshell.execDetached([...GlobalConfig.general.apps.explorer, root.dir])
            }
        }

        MediaGrid {
            files: fsModel
            limit: root.limit
        }

        StyledText {
            visible: fsModel.entries.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.large
            text: root.clips ? qsTr("No clips yet") : qsTr("No recordings yet")
            color: Colours.palette.m3outline
        }

        TextButton {
            Layout.alignment: Qt.AlignHCenter
            visible: fsModel.entries.length > root.limit
            text: qsTr("Show more")
            type: TextButton.Tonal
            onClicked: root.limit += 24
        }
    }
}
