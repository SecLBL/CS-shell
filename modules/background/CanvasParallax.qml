pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

// Wallpaper parallax for the canvas pan (hypr/scripts/canvas), as Iridium's
// ParallaxLayer does it: the wallpaper is always zoomed by `zoom`; the pan stream
// (CanvasPan) moves it by `strength` of the pan, per workspace, soft-capped by the
// zoom's overscan so no edge shows, followed by a critically damped spring.
// Switching workspaces glides to that workspace's offset.
Item {
    id: root

    required property ShellScreen screen

    readonly property real zoom: 1.2
    readonly property real strength: 0.15     // wallpaper px per canvas px
    readonly property real springW: 24        // spring stiffness, higher follows tighter
    readonly property real switchDuration: 0.65

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property int wsId: monitor?.activeWorkspace?.id ?? 0

    readonly property real maxX: screen.width * (zoom - 1) / 2
    readonly property real maxY: screen.height * (zoom - 1) / 2
    property real rawX
    property real rawY
    property var saved: ({}) // workspace id -> [rawX, rawY]

    function clampX(v: real): real {
        return Math.max(-2 * maxX, Math.min(2 * maxX, v));
    }
    function clampY(v: real): real {
        return Math.max(-2 * maxY, Math.min(2 * maxY, v));
    }
    function soft(v: real, max: real): real {
        return max > 0 ? max * Math.tanh(v / max) : 0;
    }
    readonly property real targetX: soft(clampX(rawX), maxX)
    readonly property real targetY: soft(clampY(rawY), maxY)

    property int loadedWs: -1
    onWsIdChanged: {
        if (loadedWs >= 0)
            saved[loadedWs] = [rawX, rawY];
        const s = saved[wsId];
        rawX = s ? s[0] : 0;
        rawY = s ? s[1] : 0;
        if (loadedWs >= 0)
            startSwitch();
        loadedWs = wsId;
    }
    Component.onCompleted: loadedWs = wsId

    Connections {
        function onPanned(ws: int, dx: real, dy: real): void {
            if (ws !== root.wsId)
                return;
            root.rawX = root.clampX(root.rawX + dx * root.strength);
            root.rawY = root.clampY(root.rawY + dy * root.strength);
        }

        target: CanvasPan
    }

    property real offsetX
    property real offsetY
    property real vX
    property real vY

    property bool switching
    property real swT
    property real swFromX
    property real swFromY

    function startSwitch(): void {
        swFromX = offsetX;
        swFromY = offsetY;
        vX = vY = 0;
        swT = 0;
        switching = true;
    }
    function easeInOut(t: real): real {
        return t < 0.5 ? 16 * t * t * t * t * t : 1 - Math.pow(-2 * t + 2, 5) / 2;
    }
    function settled(x: real, v: real, target: real): bool {
        return Math.abs(target - x) < 0.02 && Math.abs(v) < 0.5;
    }

    FrameAnimation {
        running: root.switching || !root.settled(root.offsetX, root.vX, root.targetX) || !root.settled(root.offsetY, root.vY, root.targetY)
        onTriggered: {
            const dt = Math.min(Math.max(smoothFrameTime > 0 ? smoothFrameTime : frameTime, 0.001), 0.05);
            if (root.switching) {
                root.swT = Math.min(1, root.swT + dt / root.switchDuration);
                const e = root.easeInOut(root.swT);
                root.offsetX = root.swFromX + (root.targetX - root.swFromX) * e;
                root.offsetY = root.swFromY + (root.targetY - root.swFromY) * e;
                if (root.swT >= 1)
                    root.switching = false;
                return;
            }
            const n = Math.max(1, Math.ceil(dt / 0.002)), h = dt / n, w = root.springW;
            let x = root.offsetX, y = root.offsetY, vx = root.vX, vy = root.vY;
            for (let i = 0; i < n; i++) {
                vx += (w * w * (root.targetX - x) - 2 * w * vx) * h;
                x += vx * h;
                vy += (w * w * (root.targetY - y) - 2 * w * vy) * h;
                y += vy * h;
            }
            if (root.settled(x, vx, root.targetX)) {
                x = root.targetX;
                vx = 0;
            }
            if (root.settled(y, vy, root.targetY)) {
                y = root.targetY;
                vy = 0;
            }
            root.offsetX = x;
            root.offsetY = y;
            root.vX = vx;
            root.vY = vy;
        }
    }
}
