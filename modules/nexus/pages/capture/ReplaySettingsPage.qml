pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.misc
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property var conf: GlobalConfig.capture
    readonly property var profile: GlobalConfig.capture.replay

    // Tracks the recorder writes: enabled ones plus the optional mix track
    readonly property int tracks: {
        const a = conf.audio;
        const n = (a.system ? 1 : 0) + (a.chat && Audio.chatChainOutNode ? 1 : 0) + (a.mic ? 1 : 0);
        return n + (a.mixTrack && n > 1 ? 1 : 0);
    }
    readonly property real estimateMb: (profile.bitrate + tracks * conf.audio.bitrate) * profile.length / 8 / 1024

    title: qsTr("Replay buffer")
    isSubPage: true

    readonly property Ref replayRef: Ref {
        service: Replay
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Buffer")
        }

        OptionRow {
            first: true
            label: qsTr("Length")
            options: [15, 30, 60, 120, 180, 300, 600, 900, 1800].map(s => [s, Replay.formatDuration(s)])
            current: root.profile.length
            onPicked: v => root.profile.length = v
        }

        ToggleRow {
            text: qsTr("Keep buffer on disk instead of RAM")
            checked: root.profile.storage === "disk"
            onToggled: root.profile.storage = checked ? "disk" : "ram"
        }

        OptionRow {
            visible: Hypr.monitors.values.length > 1
            label: qsTr("Monitor")
            options: [["", qsTr("Focused")], ...Hypr.monitors.values.map(m => [m.name, m.name])]
            current: root.profile.monitor
            onPicked: v => root.profile.monitor = v
        }

        ToggleRow {
            last: true
            text: qsTr("Clear after saving")
            checked: root.profile.restartOnSave
            onToggled: root.profile.restartOnSave = checked
        }

        VideoProfileSection {
            profile: root.profile
        }

        SectionHeader {
            text: qsTr("Size")
        }

        InfoRow {
            first: true
            last: !Replay.running
            icon: root.profile.storage === "disk" ? "hard_drive" : "memory"
            label: qsTr("Buffer")
            subtext: root.profile.bitrateMode === "cbr" ? qsTr("Video + %n audio track(s)", "", root.tracks) : qsTr("Varies with quality-based bitrate")
            value: root.profile.bitrateMode === "cbr" ? `≈ ${Math.round(root.estimateMb)} MB` : "—"
        }

        InfoRow {
            visible: Replay.running
            icon: "monitoring"
            label: qsTr("In use now")
            subtext: qsTr("Including the recorder itself")
            value: `${Math.round(Replay.rssMb)} MB`
        }

        RowButton {
            visible: Replay.running
            last: true
            icon: "restart_alt"
            text: qsTr("Restart to apply changes")
            onClicked: Replay.restart()
        }
    }
}
