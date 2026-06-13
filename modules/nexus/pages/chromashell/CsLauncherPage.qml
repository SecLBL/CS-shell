import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Launcher")
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
            subtext: qsTr("Enable the launcher")
            checked: GlobalConfig.launcher.enabled
            onToggled: GlobalConfig.launcher.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show on hover")
            subtext: qsTr("Reveal the launcher when the cursor reaches the screen edge")
            checked: GlobalConfig.launcher.showOnHover
            onToggled: GlobalConfig.launcher.showOnHover = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Vim keybinds")
            subtext: qsTr("Navigate the launcher with vim keys")
            checked: GlobalConfig.launcher.vimKeybinds
            onToggled: GlobalConfig.launcher.vimKeybinds = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Dangerous actions")
            subtext: qsTr("Allow actions like shutdown and reboot from the launcher")
            checked: GlobalConfig.launcher.enableDangerousActions
            onToggled: GlobalConfig.launcher.enableDangerousActions = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Max shown")
            subtext: qsTr("Results visible at once")
            value: GlobalConfig.launcher.maxShown
            from: 1
            to: 20
            stepSize: 1
            onMoved: v => GlobalConfig.launcher.maxShown = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Max wallpapers")
            subtext: qsTr("Wallpapers visible at once in the wallpaper view")
            value: GlobalConfig.launcher.maxWallpapers
            from: 1
            to: 30
            stepSize: 1
            onMoved: v => GlobalConfig.launcher.maxWallpapers = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the launcher reveals")
            value: GlobalConfig.launcher.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.launcher.dragThreshold = Math.round(v)
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Special prefix")
            subtext: qsTr("Prefix for special views (wallpapers, schemes, …)")
            value: GlobalConfig.launcher.specialPrefix
            onEdited: v => GlobalConfig.launcher.specialPrefix = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Action prefix")
            subtext: qsTr("Prefix for launcher actions")
            value: GlobalConfig.launcher.actionPrefix
            onEdited: v => GlobalConfig.launcher.actionPrefix = v
        }

        SectionHeader {
            text: qsTr("Apps")
        }

        CsStringListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Favourite apps")
            subtext: qsTr("Regexes matched against desktop entry ids")
            values: GlobalConfig.launcher.favouriteApps
            onEdited: v => GlobalConfig.launcher.favouriteApps = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Hidden apps")
            subtext: qsTr("Regexes matched against desktop entry ids")
            values: GlobalConfig.launcher.hiddenApps
            onEdited: v => GlobalConfig.launcher.hiddenApps = v
        }

        SectionHeader {
            text: qsTr("Fuzzy search")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Apps")
            subtext: qsTr("Use fuzzy matching for apps")
            checked: GlobalConfig.launcher.useFuzzy.apps
            onToggled: GlobalConfig.launcher.useFuzzy.apps = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Actions")
            subtext: qsTr("Use fuzzy matching for actions")
            checked: GlobalConfig.launcher.useFuzzy.actions
            onToggled: GlobalConfig.launcher.useFuzzy.actions = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Schemes")
            subtext: qsTr("Use fuzzy matching for colour schemes")
            checked: GlobalConfig.launcher.useFuzzy.schemes
            onToggled: GlobalConfig.launcher.useFuzzy.schemes = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Variants")
            subtext: qsTr("Use fuzzy matching for scheme variants")
            checked: GlobalConfig.launcher.useFuzzy.variants
            onToggled: GlobalConfig.launcher.useFuzzy.variants = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Wallpapers")
            subtext: qsTr("Use fuzzy matching for wallpapers")
            checked: GlobalConfig.launcher.useFuzzy.wallpapers
            onToggled: GlobalConfig.launcher.useFuzzy.wallpapers = checked
        }

        SectionHeader {
            text: qsTr("Actions")
        }

        CsObjectListRow {
            Layout.fillWidth: true
            first: true
            last: true
            label: qsTr("Launcher actions")
            subtext: qsTr("Command is a JSON array, e.g. [\"systemctl\", \"poweroff\"]")
            values: GlobalConfig.launcher.actions
            titleKey: "name"
            defaultEntry: ({
                    name: "",
                    icon: "",
                    description: "",
                    command: []
                })
            fields: [
                {
                    key: "name",
                    label: qsTr("Name"),
                    type: "string"
                },
                {
                    key: "icon",
                    label: qsTr("Icon"),
                    type: "string"
                },
                {
                    key: "description",
                    label: qsTr("Description"),
                    type: "string"
                },
                {
                    key: "command",
                    label: qsTr("Command"),
                    type: "json"
                },
                {
                    key: "dangerous",
                    label: qsTr("Dangerous"),
                    type: "bool"
                }
            ]
            onEdited: v => GlobalConfig.launcher.actions = v
        }
    }
}
