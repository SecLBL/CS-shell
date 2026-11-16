import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.services
import qs.modules.nexus.common

// Resolution, frame rate and bitrate of a capture.record / capture.replay profile
ColumnLayout {
    id: root

    required property var profile
    property bool first

    // Largest shorter side and refresh rate over all monitors, to offer only useful caps
    readonly property int maxShort: Math.max(0, ...Hypr.monitors.values.map(m => Math.min(m.lastIpcObject.width ?? 0, m.lastIpcObject.height ?? 0)))
    readonly property int maxRate: Math.max(60, ...Hypr.monitors.values.map(m => Math.round(m.lastIpcObject.refreshRate ?? 0)))

    Layout.fillWidth: true
    spacing: Tokens.spacing.extraSmall / 2

    SectionHeader {
        first: root.first
        text: qsTr("Video")
    }

    SegmentRow {
        first: true
        label: qsTr("Resolution")
        options: [[0, qsTr("Native")], ...[1440, 1080, 720].filter(h => h < root.maxShort).map(h => [h, `${h}p`])]
        current: root.profile.resolution
        onPicked: v => root.profile.resolution = v
    }

    SegmentRow {
        label: qsTr("Frame rate")
        options: [[0, qsTr("Native")], ...[30, 60, 120].filter(f => f < root.maxRate).map(f => [f, String(f)])]
        current: root.profile.fps
        onPicked: v => root.profile.fps = v
    }

    SegmentRow {
        label: qsTr("Bitrate")
        options: [["qp", qsTr("By quality")], ["cbr", qsTr("Fixed")]]
        current: root.profile.bitrateMode === "cbr" ? "cbr" : "qp"
        onPicked: v => root.profile.bitrateMode = v
    }

    SegmentRow {
        visible: root.profile.bitrateMode !== "cbr"
        last: true
        label: qsTr("Quality")
        options: [["medium", qsTr("Medium")], ["high", qsTr("High")], ["very_high", qsTr("Very high")], ["ultra", qsTr("Ultra")]]
        current: root.profile.quality
        onPicked: v => root.profile.quality = v
    }

    StepperRow {
        visible: root.profile.bitrateMode === "cbr"
        last: true
        label: qsTr("Mbit/s")
        subtext: qsTr("≈ %1 MB per minute").arg(Math.round(root.profile.bitrate * 60 / 8 / 1024))
        value: root.profile.bitrate / 1000
        from: 1
        to: 100
        stepSize: 1
        onMoved: v => root.profile.bitrate = Math.round(v) * 1000
    }
}
