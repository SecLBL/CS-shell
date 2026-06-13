import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Nexus")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Wallpapers per row")
            subtext: qsTr("Columns in the wallpaper picker grid")
            value: GlobalConfig.nexus.wallpapersPerRow
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.nexus.wallpapersPerRow = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Network rescan interval")
            subtext: qsTr("How often available networks are rescanned (ms)")
            value: GlobalConfig.nexus.networkRescanInterval
            from: 1000
            to: 120000
            stepSize: 1000
            onMoved: v => GlobalConfig.nexus.networkRescanInterval = Math.round(v)
        }
    }
}
