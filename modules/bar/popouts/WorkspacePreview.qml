pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services

// Mini map of a workspace, shown when hovering it in the bar: every window as a
// live screencopy at its real place. A canvas workspace (hypr/scripts/canvas)
// with windows panned off screen zooms out until all of them fit; the screen
// itself is then outlined. Dragging moves that screen outline over the canvas
// like a minimap: the floating windows of the workspace move the opposite way.
Item {
    id: root

    required property int ws

    readonly property list<HyprlandToplevel> toplevels: Hypr.toplevelsForWs(ws, GlobalConfig.bar.workspaces.ignoredTags)
    readonly property var mon: Hypr.workspaces.values.find(w => w.id === ws)?.monitor?.lastIpcObject ?? null

    // logical monitor rect: width/height are the unrotated mode
    readonly property rect screenRect: {
        if (!mon)
            return Qt.rect(0, 0, 1920, 1080);
        const rotated = mon.transform % 2 === 1;
        const s = mon.scale || 1;
        return Qt.rect(mon.x, mon.y, (rotated ? mon.height : mon.width) / s, (rotated ? mon.width : mon.height) / s);
    }

    // the screen, grown to every window on the workspace
    readonly property rect liveArea: {
        let l = screenRect.x, t = screenRect.y, r = screenRect.x + screenRect.width, b = screenRect.y + screenRect.height;
        for (const tl of toplevels) {
            const o = tl.lastIpcObject;
            if (!o?.at)
                continue;
            l = Math.min(l, o.at[0]);
            t = Math.min(t, o.at[1]);
            r = Math.max(r, o.at[0] + o.size[0]);
            b = Math.max(b, o.at[1] + o.size[1]);
        }
        return Qt.rect(l, t, r - l, b - t);
    }
    readonly property real liveFactor: Math.min(Tokens.sizes.bar.windowPreviewSize / liveArea.width, Tokens.sizes.bar.windowPreviewSize / liveArea.height)

    // frozen while dragging, otherwise the map would rescale under the cursor
    readonly property rect area: dragging ? dragArea : liveArea
    readonly property real factor: dragging ? dragFactor : liveFactor
    readonly property bool zoomedOut: area.width > screenRect.width || area.height > screenRect.height

    property bool dragging
    property rect dragArea
    property real dragFactor: 1
    property var dragStart: ({}) // floating window address -> [x, y] at press
    property point pressPos
    property point dragDelta     // logical px the screen outline moved (windows move by -dragDelta)
    property point sentDelta

    function panTo(): void {
        if (dragDelta.x === sentDelta.x && dragDelta.y === sentDelta.y)
            return;
        CanvasPan.panned(ws, sentDelta.x - dragDelta.x, sentDelta.y - dragDelta.y); // wallpaper parallax
        sentDelta = dragDelta;
        Hypr.extras.batchMessage(Object.entries(dragStart).map(([addr, p]) => `dispatch hl.dsp.window.move({ window = "address:${addr}", x = ${Math.round(p[0] - dragDelta.x)}, y = ${Math.round(p[1] - dragDelta.y)}, relative = false })`));
    }

    // canvas.hold() (hypr config/canvas.lua): no move animation on these windows while
    // dragging, or they trail far behind the map
    function hold(on: bool): void {
        Hypr.extras.message(`eval if canvas then canvas.hold(${ws}, ${on}) end`);
    }

    implicitWidth: area.width * factor
    implicitHeight: area.height * factor

    // popout closed mid-drag: give the windows their animation back
    Component.onDestruction: if (dragging) hold(false)

    // window positions change without a Hyprland event while panning a canvas
    Timer {
        interval: 250
        running: !root.dragging
        repeat: true
        triggeredOnStart: true
        onTriggered: Hyprland.refreshToplevels()
    }

    // windows move without animation, so send often enough for high refresh rates
    Timer {
        interval: 8
        running: root.dragging
        repeat: true
        onTriggered: root.panTo()
    }

    // screen in map coordinates, moved by a drag
    readonly property rect screenBox: Qt.rect((screenRect.x + (dragging ? dragDelta.x : 0) - area.x) * factor, (screenRect.y + (dragging ? dragDelta.y : 0) - area.y) * factor, screenRect.width * factor, screenRect.height * factor)

    StyledRect {
        x: root.screenBox.x
        y: root.screenBox.y
        width: root.screenBox.width
        height: root.screenBox.height
        radius: Tokens.rounding.small
        color: Colours.tPalette.m3surfaceContainer
        visible: !root.dragging
    }

    Repeater {
        // tiled first, floating on top (like Hyprland draws them)
        model: ScriptModel {
            values: [...root.toplevels].sort((a, b) => (a.lastIpcObject.floating ? 1 : 0) - (b.lastIpcObject.floating ? 1 : 0))
        }

        StyledClippingRect {
            id: win

            required property HyprlandToplevel modelData
            readonly property var ipc: modelData.lastIpcObject
            // while dragging the map stays put (the screen outline moves) instead of the 250 ms refresh
            readonly property var start: root.dragging ? root.dragStart[ipc.address] : undefined
            readonly property point pos: start ? Qt.point(start[0], start[1]) : Qt.point(ipc.at[0], ipc.at[1])

            x: (pos.x - root.area.x) * root.factor
            y: (pos.y - root.area.y) * root.factor
            width: ipc.size[0] * root.factor
            height: ipc.size[1] * root.factor
            radius: Tokens.rounding.extraSmall
            color: Colours.tPalette.m3surfaceContainerHigh

            Behavior on x {
                enabled: !root.dragging

                Anim {}
            }
            Behavior on y {
                enabled: !root.dragging

                Anim {}
            }

            ScreencopyView {
                anchors.fill: parent
                captureSource: win.modelData.wayland // qmllint disable unresolved-type
                live: true
            }
        }
    }

    // screen outline above the windows: what you see now / will see after the drag
    StyledRect {
        x: root.screenBox.x
        y: root.screenBox.y
        width: root.screenBox.width
        height: root.screenBox.height
        radius: Tokens.rounding.small
        color: "transparent"
        border.width: root.dragging || root.zoomedOut ? 2 : 0
        border.color: root.dragging ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: event => {
            const start = {};
            for (const tl of root.toplevels)
                if (tl.lastIpcObject.floating)
                    start[tl.lastIpcObject.address] = tl.lastIpcObject.at;
            root.dragStart = start;
            root.dragArea = root.liveArea;
            root.dragFactor = root.liveFactor;
            root.pressPos = Qt.point(event.x, event.y);
            root.dragDelta = root.sentDelta = Qt.point(0, 0);
            root.dragging = true;
            root.hold(true);
        }
        onPositionChanged: event => {
            if (root.dragging)
                root.dragDelta = Qt.point((event.x - root.pressPos.x) / root.dragFactor, (event.y - root.pressPos.y) / root.dragFactor);
        }
        onReleased: release()
        onCanceled: release()

        function release(): void {
            if (!root.dragging)
                return;
            root.panTo();
            root.dragging = false;
            root.hold(false);
            Hyprland.refreshToplevels();
        }
    }
}
