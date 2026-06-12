import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.containers
import qs.services

Scope {
    LazyLoader {
        active: CassetteState.open

        StyledWindow {
            id: win

            screen: {
                const screens = Screens.screens;
                for (let i = 0; i < screens.length; i++)
                    if (screens[i].name === CassetteState.screenName)
                        return screens[i];
                return screens[0] ?? null;
            }
            name: "cassette"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            mask: Region {
                x: content.x
                y: content.y
                width: content.width
                height: content.height
            }

            CassetteContent {
                id: content
            }
        }
    }
}
