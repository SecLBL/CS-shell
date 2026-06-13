import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Sidebar")
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
            subtext: qsTr("Enable the sidebar")
            checked: GlobalConfig.sidebar.enabled
            onToggled: GlobalConfig.sidebar.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the sidebar reveals")
            value: GlobalConfig.sidebar.dragThreshold
            from: 0
            to: 300
            stepSize: 10
            onMoved: v => GlobalConfig.sidebar.dragThreshold = Math.round(v)
        }
    }
}
