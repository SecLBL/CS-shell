pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.utils

Singleton {
    id: root

    property bool enabled: false
    property date enabledSince

    onEnabledChanged: {
        if (enabled)
            root.enabledSince = new Date();
        if (storage.loaded)
            storage.setText(JSON.stringify({ enabled: root.enabled, enabledSince: root.enabledSince }));
    }

    FileView {
        id: storage

        property bool loaded: false

        printErrors: false
        path: `${Paths.state}/idle.json`

        onLoaded: {
            const data = JSON.parse(text());
            root.enabled = data.enabled ?? false;
            if (data.enabledSince)
                root.enabledSince = new Date(data.enabledSince);
            loaded = true;
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                Qt.callLater(() => setText(JSON.stringify({ enabled: false })));
            loaded = true;
        }
    }

    IdleInhibitor {
        enabled: root.enabled
        window: PanelWindow {
            implicitWidth: 1
            implicitHeight: 1
            color: "transparent"
            mask: Region {}
        }
    }

    Process {
        running: root.enabled
        command: ["systemd-inhibit", "--what=sleep:idle", "--mode=block",
                  "--who=Caelestia", "--why=Keep Awake", "tail", "-f", "/dev/null"]
    }

    IpcHandler {
        function isEnabled(): bool {
            return root.enabled;
        }

        function toggle(): void {
            root.enabled = !root.enabled;
        }

        function enable(): void {
            root.enabled = true;
        }

        function disable(): void {
            root.enabled = false;
        }

        target: "idleInhibitor"
    }
}
