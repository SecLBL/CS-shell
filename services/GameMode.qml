pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.services

Singleton {
    id: root

    property alias enabled: props.enabled

    function setDynamicConfs(): void {
        // hyprctl keyword doesn't work with the Lua parser; use eval + hl.config instead.
        Hypr.extras.message(
            "eval hl.config({ animations = { enabled = false }," +
            " decoration = { shadow = { enabled = false }, blur = { enabled = false }, rounding = 0," +
            " inactive_opacity = 1.0, dim_inactive = false }," +
            " general = { gaps_in = 0, gaps_out = 0, border_size = 1, allow_tearing = true } })"
        );
        // rules.lua sets opacity 0.8 override for all windows; override it back to 1.0.
        // Later rules take precedence, so this wins over the existing rule.
        // hyprctl reload on disable clears this runtime rule.
        Hypr.extras.message(
            "eval hl.window_rule({ match={ class='.*' }, opacity='1.0 override 1.0 override' })"
        );
    }

    onEnabledChanged: {
        if (enabled) {
            setDynamicConfs();
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Game mode enabled"), qsTr("Disabled Hyprland animations, blur, gaps and shadows"), "gamepad");
        } else {
            Hypr.extras.message("reload");
            if (GlobalConfig.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Game mode disabled"), qsTr("Hyprland settings restored"), "gamepad");
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
