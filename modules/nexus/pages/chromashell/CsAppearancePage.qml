import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Appearance")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Scaling")
        }

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Deform scale")
            subtext: qsTr("Strength of squish/deform animations")
            value: GlobalConfig.appearance.deformScale
            from: 0
            to: 2
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.deformScale = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Rounding scale")
            subtext: qsTr("Multiplier for all corner radii")
            value: GlobalConfig.appearance.rounding.scale
            from: 0
            to: 3
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.rounding.scale = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Spacing scale")
            subtext: qsTr("Multiplier for all spacing values")
            value: GlobalConfig.appearance.spacing.scale
            from: 0
            to: 3
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.spacing.scale = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Padding scale")
            subtext: qsTr("Multiplier for all padding values")
            value: GlobalConfig.appearance.padding.scale
            from: 0
            to: 3
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.padding.scale = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Animation speed scale")
            subtext: qsTr("Multiplier for all animation durations")
            value: GlobalConfig.appearance.anim.durations.scale
            from: 0
            to: 3
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.anim.durations.scale = v
        }

        SectionHeader {
            text: qsTr("Transparency & blur")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Transparency")
            subtext: qsTr("Make shell surfaces translucent")
            checked: GlobalConfig.appearance.transparency.enabled
            onToggled: GlobalConfig.appearance.transparency.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Base opacity")
            subtext: qsTr("Opacity of base surfaces")
            value: GlobalConfig.appearance.transparency.base
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.transparency.base = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Layer opacity")
            subtext: qsTr("Opacity of layered surfaces")
            value: GlobalConfig.appearance.transparency.layers
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.transparency.layers = v
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Blur")
            subtext: qsTr("Blur behind translucent shell surfaces")
            checked: GlobalConfig.appearance.blur.enabled
            onToggled: GlobalConfig.appearance.blur.enabled = checked
        }

        SectionHeader {
            text: qsTr("Fonts")
        }

        NavRow {
            first: true
            last: true
            icon: "font_download"
            label: qsTr("Fonts")
            status: qsTr("Families, sizes, weights, variable axes")
            onClicked: root.nState.openSubPage(17)
        }
    }
}
