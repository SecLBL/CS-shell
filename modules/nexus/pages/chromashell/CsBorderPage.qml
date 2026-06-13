import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Border")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Thickness")
            subtext: qsTr("Screen border thickness in pixels (values below 2 are clamped)")
            value: GlobalConfig.border.thickness
            from: 0
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.border.thickness = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Rounding")
            subtext: qsTr("Corner radius of the screen border")
            value: GlobalConfig.border.rounding
            from: 0
            to: 100
            stepSize: 1
            onMoved: v => GlobalConfig.border.rounding = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Smoothing")
            subtext: qsTr("Corner smoothing of the screen border")
            value: GlobalConfig.border.smoothing
            from: 0
            to: 100
            stepSize: 1
            onMoved: v => GlobalConfig.border.smoothing = Math.round(v)
        }
    }
}
