pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.effects
import qs.services
import qs.utils
import qs.modules.bar.components.workspaces
import qs.modules.nexus
import qs.modules.bar.popouts

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

    property SystemTrayItem menuItem
    property real menuY

    // Tray menu: the bar's TrayMenu in a plain popup (bar popouts live in the hidden drawers window)
    PopupWindow {
        id: menuPopup

        visible: root.menuItem !== null && root.visible
        anchor.window: root
        anchor.rect.x: root.width
        anchor.rect.y: root.menuY
        implicitWidth: Math.max(1, (menuLoader.item?.implicitWidth ?? 0) + contentItem.Tokens.padding.large * 2)
        implicitHeight: Math.max(1, (menuLoader.item?.implicitHeight ?? 0) + contentItem.Tokens.padding.large * 2)
        color: "transparent"
        contentItem.Config.screen: root.screen.name
        contentItem.Tokens.screen: root.screen.name

        StyledRect {
            anchors.fill: parent
            color: Colours.palette.m3surface
            radius: Tokens.rounding.large
        }

        Loader {
            id: menuLoader

            anchors.centerIn: parent
            active: menuPopup.visible

            sourceComponent: TrayMenu {
                trayItem: root.menuItem.menu
                popouts: PopoutState {
                    hasCurrent: true
                    onHasCurrentChanged: if (!hasCurrent) root.menuItem = null
                }
            }
        }

        HyprlandFocusGrab {
            active: menuPopup.visible
            windows: [menuPopup, root]
            onCleared: root.menuItem = null
        }
    }

    // ponytail: no transitions, game mode is about saving frames
    Column {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Tokens.padding.large
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Tokens.spacing.medium

        Repeater {
            model: ScriptModel {
                values: SystemTray.items.values.filter(i => i.status !== Status.Passive && !GlobalConfig.bar.tray.hiddenIcons.includes(i.id))
            }

            MouseArea {
                id: trayItem

                required property SystemTrayItem modelData

                anchors.horizontalCenter: parent.horizontalCenter
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                implicitWidth: Tokens.font.body.small.pointSize * 2
                implicitHeight: Tokens.font.body.small.pointSize * 2

                onClicked: event => {
                    const item = modelData;
                    if (item.hasMenu && (event.button === Qt.RightButton || item.onlyMenu)) {
                        root.menuY = mapToItem(null, 0, 0).y;
                        root.menuItem = root.menuItem === item ? null : item;
                    }
                    else if (event.button === Qt.LeftButton)
                        item.activate();
                    else
                        item.secondaryActivate();
                }

                ColouredIcon {
                    anchors.fill: parent
                    source: Icons.getTrayIcon(trayItem.modelData.id, trayItem.modelData.icon)
                    colour: Colours.palette.m3secondary
                    layer.enabled: Config.bar.tray.recolour
                }
            }
        }

        BarButton {
            icon: "settings"
            colour: Colours.palette.m3onSurfaceVariant
            onClicked: WindowFactory.create()
        }

        BarButton {
            icon: "gamepad"
            onClicked: GameMode.enabled = false
        }
    }

    component BarButton: Item {
        id: button

        property alias icon: icon.text
        property alias colour: icon.color
        signal clicked

        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: icon.implicitHeight + Tokens.padding.small
        implicitHeight: icon.implicitHeight

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            implicitWidth: implicitHeight
            implicitHeight: icon.implicitHeight + Tokens.padding.small
            radius: Tokens.rounding.full
            onClicked: button.clicked()
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
        }
    }
}
