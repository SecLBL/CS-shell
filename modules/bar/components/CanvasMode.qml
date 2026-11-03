import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

// Layout mode of this screen's active workspace: canvas (hypr/scripts/canvas, Super+A)
// when floating windows are the majority, as in auto_layout_mode.py, otherwise tiling.
// Click switches it, through canvas.toggle() (hypr config/canvas.lua) like Super+A.
StyledRect {
    id: root

    required property ShellScreen screen

    readonly property int wsId: Hypr.monitorFor(screen)?.activeWorkspace?.id ?? 0
    readonly property bool canvas: {
        const wins = Hypr.toplevelsForWs(wsId).map(t => t.lastIpcObject);
        const floating = wins.filter(o => o.floating).length;
        return floating > 0 && floating * 2 > wins.length;
    }

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    StateLayer {
        radius: root.radius
        onClicked: {
            if (Hypr.activeWsId !== root.wsId)
                Hypr.focusWorkspace(root.wsId); // the toggle acts on the focused workspace
            Hypr.extras.message("eval if canvas then canvas.toggle() end");
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: root.canvas ? "pan_tool" : "grid_view"
        color: root.canvas ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
        animate: true
    }
}
