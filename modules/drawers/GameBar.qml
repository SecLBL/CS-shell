pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.bar.components.workspaces

// Slim bar for game mode: replaces the fullscreen drawers window (which holds most of the shell's VRAM)
StyledWindow {
    id: root

    name: "gamebar"
    color: Colours.palette.m3surface
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.bottom: true
    anchors.left: true

    Workspaces {
        anchors.top: parent.top
        anchors.topMargin: Tokens.padding.large
        anchors.horizontalCenter: parent.horizontalCenter

        screen: root.screen
        fullscreen: false
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Tokens.padding.large
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: icon.implicitHeight + Tokens.padding.small
        implicitHeight: icon.implicitHeight

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            implicitWidth: implicitHeight
            implicitHeight: icon.implicitHeight + Tokens.padding.small
            radius: Tokens.rounding.full
            onClicked: GameMode.enabled = false
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent

            text: "gamepad"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
        }
    }
}
