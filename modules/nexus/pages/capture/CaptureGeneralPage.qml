pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.nexus.common
import qs.modules.nexus.pages.chromashell

PageBase {
    id: root

    readonly property var conf: GlobalConfig.capture
    // Codecs this GPU can encode, from `gpu-screen-recorder --info`
    property list<string> codecs: []
    readonly property var codecNames: ({
            h264: "H.264",
            hevc: "HEVC",
            hevc_hdr: "HEVC HDR",
            hevc_10bit: "HEVC 10-bit",
            av1: "AV1",
            av1_hdr: "AV1 HDR",
            av1_10bit: "AV1 10-bit",
            vp8: "VP8",
            vp9: "VP9"
        })

    // Codec names usable with the chosen encoder (Vulkan ones without their suffix)
    readonly property list<string> vulkanCodecs: codecs.filter(c => c.endsWith("_vulkan")).map(c => c.slice(0, -7))
    readonly property list<string> encoderCodecs: conf.encoder === "vulkan" ? vulkanCodecs : codecs.filter(c => !c.endsWith("_vulkan") && !c.endsWith("_software"))

    title: qsTr("General")
    isSubPage: true

    readonly property Process codecProc: Process {
        running: true
        command: ["caelestia", "replay", "codecs"]
        stdout: StdioCollector {
            onStreamFinished: root.codecs = text.trim().split("\n").filter(c => c)
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Encoding")
        }

        SegmentRow {
            first: true
            label: qsTr("Encoder")
            subtext: root.conf.encoder === "vulkan" ? qsTr("Less VRAM · experimental") : root.conf.encoder === "cpu" ? qsTr("No VRAM · high CPU load · H.264 only") : ""
            options: [["gpu", qsTr("GPU")], ...(root.vulkanCodecs.length ? [["vulkan", "Vulkan"]] : []), ...(root.codecs.includes("h264_software") ? [["cpu", qsTr("CPU")]] : [])]
            current: root.conf.encoder
            onPicked: v => {
                root.conf.encoder = v;
                // Keep the codec valid for the new encoder
                if (!root.encoderCodecs.includes(root.conf.codec))
                    root.conf.codec = "auto";
            }
        }

        OptionRow {
            visible: root.conf.encoder !== "cpu"
            label: qsTr("Video codec")
            options: [["auto", qsTr("Automatic")], ...root.encoderCodecs.map(c => [c, root.codecNames[c] ?? c])]
            current: root.conf.codec
            onPicked: v => root.conf.codec = v
        }

        SegmentRow {
            label: qsTr("Container")
            options: [["mkv", "MKV"], ["mp4", "MP4"]]
            current: root.conf.container
            onPicked: v => root.conf.container = v
        }

        SegmentRow {
            label: qsTr("Frame rate mode")
            options: [["vfr", qsTr("Variable")], ["cfr", qsTr("Constant")]]
            current: root.conf.framerateMode
            onPicked: v => root.conf.framerateMode = v
        }

        ToggleRow {
            last: true
            text: qsTr("Record cursor")
            checked: root.conf.cursor
            onToggled: root.conf.cursor = checked
        }

        SectionHeader {
            text: qsTr("Files")
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Recordings")
            subtext: root.conf.recordingsDir ? "" : Paths.shortenHome(Paths.recsdir)
            value: root.conf.recordingsDir
            onEdited: v => root.conf.recordingsDir = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Clips")
            subtext: root.conf.clipsDir ? "" : Paths.shortenHome(Replay.clipsDir)
            value: root.conf.clipsDir
            onEdited: v => root.conf.clipsDir = v
        }

        ToggleRow {
            last: true
            text: qsTr("App name in clip file names")
            checked: root.conf.appInFileName
            onToggled: root.conf.appInFileName = checked
        }

        SectionHeader {
            text: qsTr("Feedback")
        }

        ToggleRow {
            first: true
            text: qsTr("Sound when a clip is saved")
            checked: root.conf.clipSound
            onToggled: root.conf.clipSound = checked
        }

        ToggleRow {
            last: true
            text: qsTr("Toast when the buffer starts or stops")
            checked: root.conf.toasts
            onToggled: root.conf.toasts = checked
        }

        SectionHeader {
            text: qsTr("Clean up clips")
        }

        OptionRow {
            first: true
            label: qsTr("Delete after")
            options: [[0, qsTr("Never")], ...[3, 7, 14, 30, 90].map(d => [d, qsTr("%1 days").arg(d)])]
            current: root.conf.cleanup.maxAgeDays
            onPicked: v => root.conf.cleanup.maxAgeDays = v
        }

        OptionRow {
            last: true
            label: qsTr("Folder limit")
            options: [[0, qsTr("None")], ...[5, 10, 25, 50, 100].map(g => [g, `${g} GB`])]
            current: root.conf.cleanup.maxSizeGb
            onPicked: v => root.conf.cleanup.maxSizeGb = v
        }
    }
}
