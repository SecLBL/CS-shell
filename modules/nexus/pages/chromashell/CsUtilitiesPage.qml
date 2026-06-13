import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    // Values checked in modules/utilities/toasts/Toasts.qml
    readonly property list<MenuItem> fullscreenItems: [
        MenuItem {
            text: "off"
        },
        MenuItem {
            text: "important"
        },
        MenuItem {
            text: "all"
        }
    ]

    title: qsTr("Utilities")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("Enable the utilities drawer")
            checked: GlobalConfig.utilities.enabled
            onToggled: GlobalConfig.utilities.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Max toasts")
            subtext: qsTr("Toasts visible at once")
            value: GlobalConfig.utilities.maxToasts
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.utilities.maxToasts = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Toasts")
        }

        SelectRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Fullscreen toasts")
            subtext: qsTr("Which toasts to show over fullscreen windows")
            menuItems: root.fullscreenItems
            active: root.fullscreenItems.find(i => i.text === GlobalConfig.utilities.toasts.fullscreen) ?? root.fullscreenItems[0]
            onSelected: item => GlobalConfig.utilities.toasts.fullscreen = item.text
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Config loaded")
            subtext: qsTr("Toast when the shell config is (re)loaded")
            checked: GlobalConfig.utilities.toasts.configLoaded
            onToggled: GlobalConfig.utilities.toasts.configLoaded = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Charging changed")
            subtext: qsTr("Toast when the charger is plugged or unplugged")
            checked: GlobalConfig.utilities.toasts.chargingChanged
            onToggled: GlobalConfig.utilities.toasts.chargingChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Game mode changed")
            subtext: qsTr("Toast when game mode is toggled")
            checked: GlobalConfig.utilities.toasts.gameModeChanged
            onToggled: GlobalConfig.utilities.toasts.gameModeChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Do not disturb changed")
            subtext: qsTr("Toast when do not disturb is toggled")
            checked: GlobalConfig.utilities.toasts.dndChanged
            onToggled: GlobalConfig.utilities.toasts.dndChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Audio output changed")
            subtext: qsTr("Toast when the audio output device changes")
            checked: GlobalConfig.utilities.toasts.audioOutputChanged
            onToggled: GlobalConfig.utilities.toasts.audioOutputChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Audio input changed")
            subtext: qsTr("Toast when the audio input device changes")
            checked: GlobalConfig.utilities.toasts.audioInputChanged
            onToggled: GlobalConfig.utilities.toasts.audioInputChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Caps lock changed")
            subtext: qsTr("Toast when caps lock is toggled")
            checked: GlobalConfig.utilities.toasts.capsLockChanged
            onToggled: GlobalConfig.utilities.toasts.capsLockChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Num lock changed")
            subtext: qsTr("Toast when num lock is toggled")
            checked: GlobalConfig.utilities.toasts.numLockChanged
            onToggled: GlobalConfig.utilities.toasts.numLockChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Keyboard layout changed")
            subtext: qsTr("Toast when the keyboard layout changes")
            checked: GlobalConfig.utilities.toasts.kbLayoutChanged
            onToggled: GlobalConfig.utilities.toasts.kbLayoutChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Keyboard limit")
            subtext: qsTr("Toast when the keyboard backlight limit is hit")
            checked: GlobalConfig.utilities.toasts.kbLimit
            onToggled: GlobalConfig.utilities.toasts.kbLimit = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("VPN changed")
            subtext: qsTr("Toast when the VPN connects or disconnects")
            checked: GlobalConfig.utilities.toasts.vpnChanged
            onToggled: GlobalConfig.utilities.toasts.vpnChanged = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Now playing")
            subtext: qsTr("Toast when the playing track changes")
            checked: GlobalConfig.utilities.toasts.nowPlaying
            onToggled: GlobalConfig.utilities.toasts.nowPlaying = checked
        }

        SectionHeader {
            text: qsTr("VPN")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("Enable VPN integration")
            checked: GlobalConfig.utilities.vpn.enabled
            onToggled: GlobalConfig.utilities.vpn.enabled = checked
        }

        CsJsonRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Providers")
            subtext: qsTr("JSON list of provider names or objects (see services/VPN.qml)")
            value: GlobalConfig.utilities.vpn.provider
            onEdited: v => GlobalConfig.utilities.vpn.provider = v
        }

        SectionHeader {
            text: qsTr("Quick toggles")
        }

        CsObjectListRow {
            Layout.fillWidth: true
            first: true
            last: true
            label: qsTr("Quick toggles")
            subtext: qsTr("Buttons in the utilities drawer, in order")
            values: GlobalConfig.utilities.quickToggles
            titleKey: "id"
            reorderable: true
            defaultEntry: ({
                    id: "wifi",
                    enabled: true
                })
            fields: [
                {
                    key: "id",
                    label: qsTr("Toggle"),
                    type: "select",
                    options: ["wifi", "bluetooth", "mic", "settings", "gameMode", "dnd", "vpn"]
                },
                {
                    key: "enabled",
                    label: qsTr("Enabled"),
                    type: "bool"
                }
            ]
            onEdited: v => GlobalConfig.utilities.quickToggles = v
        }
    }
}
