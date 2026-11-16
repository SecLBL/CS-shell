pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property var conf: GlobalConfig.capture.audio
    // Without the ChromaShell audio pipeline the default output and input are recorded
    readonly property bool pipeline: !!Audio.generalChainOutNode

    title: qsTr("Audio tracks")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Tracks")
        }

        TrackRow {
            first: true
            conf: root.conf
            track: "system"
            label: root.pipeline ? qsTr("Mix bus") : qsTr("Output")
            canProcess: root.pipeline
        }

        TrackRow {
            visible: !!Audio.chatChainOutNode
            conf: root.conf
            track: "chat"
            label: qsTr("Chat bus")
            canProcess: true
        }

        TrackRow {
            last: true
            conf: root.conf
            track: "mic"
            label: qsTr("Mic")
            canProcess: root.pipeline
        }

        SectionHeader {
            text: qsTr("Encoding")
        }

        ToggleRow {
            first: true
            text: qsTr("Extra mixed track first")
            subtext: qsTr("Most players only play the first track")
            checked: root.conf.mixTrack
            onToggled: root.conf.mixTrack = checked
        }

        SegmentRow {
            label: qsTr("Codec")
            options: [["opus", "Opus"], ["aac", "AAC"]]
            current: root.conf.codec
            onPicked: v => root.conf.codec = v
        }

        OptionRow {
            last: true
            label: qsTr("Bitrate per track")
            options: [64, 96, 128, 160, 192, 256, 320].map(b => [b, qsTr("%1 kbit/s").arg(b)])
            current: root.conf.bitrate
            onPicked: v => root.conf.bitrate = v
        }
    }
}
