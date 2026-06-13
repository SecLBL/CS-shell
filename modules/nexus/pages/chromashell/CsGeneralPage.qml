import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("General")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Logo")
            subtext: qsTr("Logo image used across the shell (empty = distro logo)")
            value: GlobalConfig.general.logo
            onEdited: v => GlobalConfig.general.logo = v
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show over fullscreen")
            subtext: qsTr("Keep shell surfaces above fullscreen windows")
            checked: GlobalConfig.general.showOverFullscreen
            onToggled: GlobalConfig.general.showOverFullscreen = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Media GIF speed adjustment")
            subtext: qsTr("How strongly the media GIF speed follows the track")
            value: GlobalConfig.general.mediaGifSpeedAdjustment
            from: 0
            to: 1000
            stepSize: 10
            onMoved: v => GlobalConfig.general.mediaGifSpeedAdjustment = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Session GIF speed")
            subtext: qsTr("Playback speed of the session menu GIF")
            value: GlobalConfig.general.sessionGifSpeed
            from: 0
            to: 3
            stepSize: 0.1
            onMoved: v => GlobalConfig.general.sessionGifSpeed = v
        }

        SectionHeader {
            text: qsTr("Default apps")
        }

        CsStringListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Terminal")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.general.apps.terminal
            onEdited: v => GlobalConfig.general.apps.terminal = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Audio")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.general.apps.audio
            onEdited: v => GlobalConfig.general.apps.audio = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Playback")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.general.apps.playback
            onEdited: v => GlobalConfig.general.apps.playback = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("File explorer")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.general.apps.explorer
            onEdited: v => GlobalConfig.general.apps.explorer = v
        }

        SectionHeader {
            text: qsTr("Idle")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Lock before sleep")
            subtext: qsTr("Lock the session before the system suspends")
            checked: GlobalConfig.general.idle.lockBeforeSleep
            onToggled: GlobalConfig.general.idle.lockBeforeSleep = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Inhibit when audio")
            subtext: qsTr("Prevent idle actions while audio is playing")
            checked: GlobalConfig.general.idle.inhibitWhenAudio
            onToggled: GlobalConfig.general.idle.inhibitWhenAudio = checked
        }

        CsObjectListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Idle timeouts")
            subtext: qsTr("Actions are a string or a JSON command array")
            values: GlobalConfig.general.idle.timeouts
            titleKey: "idleAction"
            defaultEntry: ({
                    timeout: 300,
                    idleAction: "lock"
                })
            fields: [
                {
                    key: "timeout",
                    label: qsTr("Timeout (s)"),
                    type: "int",
                    from: 5,
                    to: 7200,
                    step: 5
                },
                {
                    key: "idleAction",
                    label: qsTr("Idle action"),
                    type: "json"
                },
                {
                    key: "returnAction",
                    label: qsTr("Return action"),
                    type: "json"
                }
            ]
            onEdited: v => GlobalConfig.general.idle.timeouts = v
        }

        SectionHeader {
            text: qsTr("Battery")
        }

        CsObjectListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Warning levels")
            subtext: qsTr("Notifications shown when the battery falls to a level")
            values: GlobalConfig.general.battery.warnLevels
            titleKey: "title"
            defaultEntry: ({
                    level: 15,
                    title: "",
                    message: "",
                    icon: "battery_android_alert"
                })
            fields: [
                {
                    key: "level",
                    label: qsTr("Level (%)"),
                    type: "int",
                    from: 0,
                    to: 100,
                    step: 1
                },
                {
                    key: "title",
                    label: qsTr("Title"),
                    type: "string"
                },
                {
                    key: "message",
                    label: qsTr("Message"),
                    type: "string"
                },
                {
                    key: "icon",
                    label: qsTr("Icon"),
                    type: "string"
                },
                {
                    key: "critical",
                    label: qsTr("Critical"),
                    type: "bool"
                }
            ]
            onEdited: v => GlobalConfig.general.battery.warnLevels = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Critical level")
            subtext: qsTr("Battery percentage at which the system hibernates")
            value: GlobalConfig.general.battery.criticalLevel
            from: 0
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.general.battery.criticalLevel = Math.round(v)
        }
    }
}
