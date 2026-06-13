import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Dashboard")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("Enable the dashboard")
            checked: GlobalConfig.dashboard.enabled
            onToggled: GlobalConfig.dashboard.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show on hover")
            subtext: qsTr("Reveal the dashboard when the cursor reaches the screen edge")
            checked: GlobalConfig.dashboard.showOnHover
            onToggled: GlobalConfig.dashboard.showOnHover = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the dashboard reveals")
            value: GlobalConfig.dashboard.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.dashboard.dragThreshold = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Tabs")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Dashboard tab")
            subtext: qsTr("Show the dashboard tab")
            checked: GlobalConfig.dashboard.showDashboard
            onToggled: GlobalConfig.dashboard.showDashboard = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Media tab")
            subtext: qsTr("Show the media tab")
            checked: GlobalConfig.dashboard.showMedia
            onToggled: GlobalConfig.dashboard.showMedia = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Performance tab")
            subtext: qsTr("Show the performance tab")
            checked: GlobalConfig.dashboard.showPerformance
            onToggled: GlobalConfig.dashboard.showPerformance = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Weather tab")
            subtext: qsTr("Show the weather tab")
            checked: GlobalConfig.dashboard.showWeather
            onToggled: GlobalConfig.dashboard.showWeather = checked
        }

        SectionHeader {
            text: qsTr("Polling")
        }

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Media refresh")
            subtext: qsTr("How often the media position updates (ms)")
            value: GlobalConfig.dashboard.mediaUpdateInterval
            from: 100
            to: 2000
            stepSize: 50
            onMoved: v => GlobalConfig.dashboard.mediaUpdateInterval = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("System stats refresh")
            subtext: qsTr("CPU, memory and GPU update interval (ms)")
            value: GlobalConfig.dashboard.resourceUpdateInterval
            from: 250
            to: 10000
            stepSize: 250
            onMoved: v => GlobalConfig.dashboard.resourceUpdateInterval = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Performance card")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Battery")
            subtext: qsTr("Show battery usage")
            checked: GlobalConfig.dashboard.performance.showBattery
            onToggled: GlobalConfig.dashboard.performance.showBattery = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("GPU")
            subtext: qsTr("Show GPU usage")
            checked: GlobalConfig.dashboard.performance.showGpu
            onToggled: GlobalConfig.dashboard.performance.showGpu = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("CPU")
            subtext: qsTr("Show CPU usage")
            checked: GlobalConfig.dashboard.performance.showCpu
            onToggled: GlobalConfig.dashboard.performance.showCpu = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Memory")
            subtext: qsTr("Show memory usage")
            checked: GlobalConfig.dashboard.performance.showMemory
            onToggled: GlobalConfig.dashboard.performance.showMemory = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Storage")
            subtext: qsTr("Show storage usage")
            checked: GlobalConfig.dashboard.performance.showStorage
            onToggled: GlobalConfig.dashboard.performance.showStorage = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Network")
            subtext: qsTr("Show network usage")
            checked: GlobalConfig.dashboard.performance.showNetwork
            onToggled: GlobalConfig.dashboard.performance.showNetwork = checked
        }
    }
}
