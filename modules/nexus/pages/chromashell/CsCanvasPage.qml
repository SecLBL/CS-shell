import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

// Canvas workspaces (hypr config/canvas.lua: Super+A, Super+right drag to pan)
PageBase {
    id: root

    title: qsTr("Canvas")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            text: qsTr("Windows")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            last: true
            text: qsTr("New windows follow the workspace")
            subtext: qsTr("Windows opened on a canvas workspace float, everywhere else they tile")
            checked: GlobalConfig.general.canvas.autoLayout
            onToggled: GlobalConfig.general.canvas.autoLayout = checked
        }

        SectionHeader {
            text: qsTr("Wallpaper parallax")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Parallax")
            subtext: qsTr("The wallpaper moves along a little when a canvas is panned")
            checked: GlobalConfig.background.parallax.enabled
            onToggled: GlobalConfig.background.parallax.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Zoom")
            subtext: qsTr("How far the wallpaper is zoomed in, which is also how far it can move")
            value: GlobalConfig.background.parallax.zoom
            from: 1.05
            to: 1.5
            stepSize: 0.05
            onMoved: v => GlobalConfig.background.parallax.zoom = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Strength")
            subtext: qsTr("Wallpaper movement per pixel the canvas moves")
            value: GlobalConfig.background.parallax.strength
            from: 0.05
            to: 0.5
            stepSize: 0.05
            onMoved: v => GlobalConfig.background.parallax.strength = v
        }
    }
}
