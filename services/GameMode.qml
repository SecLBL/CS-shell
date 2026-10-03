pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import Caelestia.I18n
import qs.services

Singleton {
    id: root

    property alias enabled: props.enabled

    // What game mode switches off in the shell; each part can be opted out in the settings
    readonly property bool hideBackground: enabled && GlobalConfig.utilities.gameMode.hideBackground
    readonly property bool slimShell: enabled && GlobalConfig.utilities.gameMode.slimShell
    readonly property bool opaqueShell: enabled && GlobalConfig.utilities.gameMode.opaqueShell

    function setDynamicConfs(): void {
        const conf = GlobalConfig.utilities.gameMode;
        // hyprctl keyword doesn't work with the Lua parser; use eval + hl.config instead.
        Hypr.extras.message("eval hl.config({ general = { allow_tearing = true } })");
        if (conf.disableEffects)
            Hypr.extras.message("eval hl.config({ animations = { enabled = false }," +
                " decoration = { shadow = { enabled = false }, blur = { enabled = false } } })");
        if (conf.compactLayout) {
            Hypr.extras.message("eval hl.config({ decoration = { rounding = 0, inactive_opacity = 1.0, dim_inactive = false }," +
                " general = { gaps_in = 0, gaps_out = 0, border_size = 1 } })");
            // rules.lua sets opacity 0.8 override for all windows; override it back to 1.0.
            // Later rules take precedence, so this wins over the existing rule.
            // hyprctl reload on disable clears this runtime rule.
            Hypr.extras.message("eval hl.window_rule({ match={ class='.*' }, opacity='1.0 override 1.0 override' })");
        }
        setMonitors();
    }

    // Lower resolution/refresh rate of all monitors except the main one; hyprctl reload on disable restores them.
    function setMonitors(): void {
        const conf = GlobalConfig.utilities.gameMode;
        if (conf.otherMode === "off" && !conf.otherRefreshRate)
            return;

        const names = Hypr.monitors.values.map(m => m.name);
        const main = names.includes(conf.mainMonitor) ? conf.mainMonitor : Hypr.focusedMonitor?.name;
        const height = Number(conf.otherResolution.split("x")[1]);

        for (const m of Hypr.monitors.values) {
            if (m.name === main)
                continue;

            const o = m.lastIpcObject;
            let res = `${o.width}x${o.height}`;
            if (conf.otherMode !== "off") {
                // Modes keeping this monitor's aspect ratio; take the one closest in height to the target,
                // so e.g. an ultrawide gets its own 720p-class mode
                const sizes = (o.availableModes ?? []).map(s => s.split("@")[0].split("x").map(Number)).filter(a => a[0] * o.height === a[1] * o.width);
                const target = conf.otherMode === "resolution" ? height : Math.max(...sizes.map(a => a[1])) * conf.otherScalePercent / 100;
                if (target > 0 && sizes.length) {
                    const best = sizes.reduce((a, b) => Math.abs(b[1] - target) < Math.abs(a[1] - target) ? b : a);
                    res = `${best[0]}x${best[1]}`;
                }
            }
            const hz = conf.otherRefreshRate || o.refreshRate;
            const rates = (o.availableModes ?? []).filter(s => s.startsWith(`${res}@`)).map(s => parseFloat(s.split("@")[1]));
            if (!rates.length)
                continue;

            const rate = rates.reduce((a, b) => Math.abs(b - hz) < Math.abs(a - hz) ? b : a);
            // Scale along with the resolution so the logical layout (and window sizes) stays the same
            const scale = o.scale * parseInt(res) / o.width;
            Hypr.extras.message(`eval hl.monitor({ output='${m.name}', mode='${res}@${rate}', position='${o.x}x${o.y}', scale=${scale}, transform=${o.transform} })`);
        }
    }

    onEnabledChanged: {
        // DeepFilterNet off while gaming; it is the only costly plugin in the chains.
        Quickshell.execDetached(["bash", "-c",
            'bash "${XDG_CONFIG_HOME:-$HOME/.config}/chromashell/audio/audio-param.sh" --nr-bypass "$0"', enabled && GlobalConfig.utilities.gameMode.bypassNoiseReduction ? "on" : "off"]);
        if (enabled) {
            setDynamicConfs();
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(Tr.tr("Game mode enabled"), Tr.tr("Disabled Hyprland animations, blur, gaps and shadows"), "gamepad");
        } else {
            Hypr.extras.message("reload");
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(Tr.tr("Game mode disabled"), Tr.tr("Hyprland settings restored"), "gamepad");
        }
    }

    PersistentProperties {
        id: props

        property bool enabled: Hypr.options["animations:enabled"] === false // qmllint disable missing-property

        reloadableId: "gameMode"
    }

    Connections {
        function onConfigReloaded(): void {
            if (props.enabled)
                root.setDynamicConfs();
        }

        target: Hypr
    }

    IpcHandler {
        function isEnabled(): bool {
            return props.enabled;
        }

        function toggle(): void {
            props.enabled = !props.enabled;
        }

        function enable(): void {
            props.enabled = true;
        }

        function disable(): void {
            props.enabled = false;
        }

        target: "gameMode"
    }
}
