import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("OSD")
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
            subtext: qsTr("Show the on-screen display")
            checked: GlobalConfig.osd.enabled
            onToggled: GlobalConfig.osd.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Brightness OSD")
            subtext: qsTr("Show the OSD on brightness changes")
            checked: GlobalConfig.osd.enableBrightness
            onToggled: GlobalConfig.osd.enableBrightness = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Microphone OSD")
            subtext: qsTr("Show the OSD on microphone volume changes")
            checked: GlobalConfig.osd.enableMicrophone
            onToggled: GlobalConfig.osd.enableMicrophone = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Hide delay")
            subtext: qsTr("Time before the OSD hides (ms)")
            value: GlobalConfig.osd.hideDelay
            from: 200
            to: 10000
            stepSize: 100
            onMoved: v => GlobalConfig.osd.hideDelay = Math.round(v)
        }
    }
}
