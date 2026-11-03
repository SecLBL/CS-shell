import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

// Layout mode of this screen's active workspace: canvas or tiling, as stored per
// workspace by hypr config/canvas.lua in $XDG_RUNTIME_DIR/canvas-modes.json.
// Click switches it, through canvas.toggle() like Super+A.
StyledRect {
    id: root

    required property ShellScreen screen

    readonly property int wsId: Hypr.monitorFor(screen)?.activeWorkspace?.id ?? 0
    property var modes: ({})
    readonly property bool canvas: modes[String(wsId)] === true

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    FileView {
        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/canvas-modes.json`
        watchChanges: true
        printErrors: false // missing until the first toggle
        onFileChanged: reload()
        onLoaded: {
            try {
                root.modes = JSON.parse(text());
            } catch (e) {
                root.modes = {};
            }
        }
        onLoadFailed: root.modes = {}
    }

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
