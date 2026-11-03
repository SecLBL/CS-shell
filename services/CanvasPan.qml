pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// How far a canvas (hypr config/canvas.lua) just moved, for the wallpaper parallax.
// Hyprland's canvas plugin posts "canvaspan>>ws,dx,dy" IPC events while the canvas is
// grabbed or navigated; the workspace preview's drag-pan calls panned() directly.
Singleton {
    id: root

    signal panned(ws: int, dx: real, dy: real)

    Connections {
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name !== "canvaspan")
                return;
            const p = event.data.split(",");
            if (p.length === 3)
                root.panned(parseInt(p[0]), parseFloat(p[1]), parseFloat(p[2]));
        }

        target: Hyprland
    }
}
