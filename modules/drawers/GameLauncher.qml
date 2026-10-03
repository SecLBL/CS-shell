pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.launcher as Launcher

// Game mode launcher: plain launcher-sized window, no frame, no slide animation
StyledWindow {
    id: root

    required property ScreenState screenState

    name: "gamelauncher"
    visible: GameMode.enabled && screenState.launcher && contentItem.Config.launcher.enabled
    color: Colours.palette.m3surface
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors.bottom: true
    implicitWidth: loader.implicitWidth || 630
    implicitHeight: loader.implicitHeight || 1

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.screenState.launcher = false
    }

    Loader {
        id: loader

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        active: root.visible

        sourceComponent: Launcher.Content {
            screenState: root.screenState
            panels: ShellState.componentsFor(root.screen)?.panels
            maxHeight: root.screen.height - Config.border.thickness * 2
        }
    }
}
