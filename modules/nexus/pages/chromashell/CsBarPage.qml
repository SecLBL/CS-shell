import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Bar")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Persistent")
            subtext: qsTr("Keep the bar visible at all times")
            checked: GlobalConfig.bar.persistent
            onToggled: GlobalConfig.bar.persistent = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show on hover")
            subtext: qsTr("Reveal the bar when the cursor reaches the screen edge")
            checked: GlobalConfig.bar.showOnHover
            onToggled: GlobalConfig.bar.showOnHover = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the bar reveals")
            value: GlobalConfig.bar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.bar.dragThreshold = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Scroll actions")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Workspaces")
            subtext: qsTr("Scroll on the workspaces to switch workspace")
            checked: GlobalConfig.bar.scrollActions.workspaces
            onToggled: GlobalConfig.bar.scrollActions.workspaces = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Volume")
            subtext: qsTr("Scroll on the status icons to change volume")
            checked: GlobalConfig.bar.scrollActions.volume
            onToggled: GlobalConfig.bar.scrollActions.volume = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Brightness")
            subtext: qsTr("Scroll on the clock to change brightness")
            checked: GlobalConfig.bar.scrollActions.brightness
            onToggled: GlobalConfig.bar.scrollActions.brightness = checked
        }

        SectionHeader {
            text: qsTr("Popouts")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Active window")
            subtext: qsTr("Show a popout for the active window")
            checked: GlobalConfig.bar.popouts.activeWindow
            onToggled: GlobalConfig.bar.popouts.activeWindow = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Tray")
            subtext: qsTr("Show popouts for tray icons")
            checked: GlobalConfig.bar.popouts.tray
            onToggled: GlobalConfig.bar.popouts.tray = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Status icons")
            subtext: qsTr("Show popouts for the status icons")
            checked: GlobalConfig.bar.popouts.statusIcons
            onToggled: GlobalConfig.bar.popouts.statusIcons = checked
        }

        SectionHeader {
            text: qsTr("Active window")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Compact")
            subtext: qsTr("Show only the window title")
            checked: GlobalConfig.bar.activeWindow.compact
            onToggled: GlobalConfig.bar.activeWindow.compact = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Inverted")
            subtext: qsTr("Swap the title and class positions")
            checked: GlobalConfig.bar.activeWindow.inverted
            onToggled: GlobalConfig.bar.activeWindow.inverted = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Show on hover")
            subtext: qsTr("Show the active window preview on hover")
            checked: GlobalConfig.bar.activeWindow.showOnHover
            onToggled: GlobalConfig.bar.activeWindow.showOnHover = checked
        }

        SectionHeader {
            text: qsTr("Tray")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Background")
            subtext: qsTr("Draw a background behind the tray")
            checked: GlobalConfig.bar.tray.background
            onToggled: GlobalConfig.bar.tray.background = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Recolour icons")
            subtext: qsTr("Tint tray icons to match the scheme")
            checked: GlobalConfig.bar.tray.recolour
            onToggled: GlobalConfig.bar.tray.recolour = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Compact")
            subtext: qsTr("Reduce tray spacing")
            checked: GlobalConfig.bar.tray.compact
            onToggled: GlobalConfig.bar.tray.compact = checked
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Hidden icons")
            subtext: qsTr("Tray item ids to hide")
            values: GlobalConfig.bar.tray.hiddenIcons
            onEdited: v => GlobalConfig.bar.tray.hiddenIcons = v
        }

        CsObjectListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Icon substitutions")
            subtext: qsTr("Replace a tray item's icon by id")
            values: GlobalConfig.bar.tray.iconSubs
            titleKey: "id"
            defaultEntry: ({
                    id: "",
                    icon: ""
                })
            fields: [
                {
                    key: "id",
                    label: qsTr("Item id"),
                    type: "string"
                },
                {
                    key: "icon",
                    label: qsTr("Material icon"),
                    type: "string"
                },
                {
                    key: "image",
                    label: qsTr("Image path"),
                    type: "string"
                }
            ]
            onEdited: v => GlobalConfig.bar.tray.iconSubs = v
        }

        SectionHeader {
            text: qsTr("Status icons")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Audio")
            subtext: qsTr("Show the audio icon")
            checked: GlobalConfig.bar.status.showAudio
            onToggled: GlobalConfig.bar.status.showAudio = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Microphone")
            subtext: qsTr("Show the microphone icon")
            checked: GlobalConfig.bar.status.showMicrophone
            onToggled: GlobalConfig.bar.status.showMicrophone = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Keyboard layout")
            subtext: qsTr("Show the keyboard layout")
            checked: GlobalConfig.bar.status.showKbLayout
            onToggled: GlobalConfig.bar.status.showKbLayout = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Network")
            subtext: qsTr("Show the network icon")
            checked: GlobalConfig.bar.status.showNetwork
            onToggled: GlobalConfig.bar.status.showNetwork = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Wi-Fi")
            subtext: qsTr("Show the Wi-Fi icon")
            checked: GlobalConfig.bar.status.showWifi
            onToggled: GlobalConfig.bar.status.showWifi = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Bluetooth")
            subtext: qsTr("Show the Bluetooth icon")
            checked: GlobalConfig.bar.status.showBluetooth
            onToggled: GlobalConfig.bar.status.showBluetooth = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Battery")
            subtext: qsTr("Show the battery icon")
            checked: GlobalConfig.bar.status.showBattery
            onToggled: GlobalConfig.bar.status.showBattery = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Lock status")
            subtext: qsTr("Show caps/num lock indicators")
            checked: GlobalConfig.bar.status.showLockStatus
            onToggled: GlobalConfig.bar.status.showLockStatus = checked
        }

        SectionHeader {
            text: qsTr("Clock")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Background")
            subtext: qsTr("Draw a background behind the clock")
            checked: GlobalConfig.bar.clock.background
            onToggled: GlobalConfig.bar.clock.background = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show date")
            subtext: qsTr("Show the date next to the time")
            checked: GlobalConfig.bar.clock.showDate
            onToggled: GlobalConfig.bar.clock.showDate = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Show icon")
            subtext: qsTr("Show the clock icon")
            checked: GlobalConfig.bar.clock.showIcon
            onToggled: GlobalConfig.bar.clock.showIcon = checked
        }

        SectionHeader {
            text: qsTr("Layout")
        }

        CsObjectListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Bar entries")
            subtext: qsTr("Components on the bar, in order")
            values: GlobalConfig.bar.entries
            titleKey: "id"
            reorderable: true
            defaultEntry: ({
                    id: "spacer",
                    enabled: true
                })
            fields: [
                {
                    key: "id",
                    label: qsTr("Component"),
                    type: "select",
                    options: ["logo", "workspaces", "spacer", "activeWindow", "tray", "clock", "statusIcons", "power"]
                },
                {
                    key: "enabled",
                    label: qsTr("Enabled"),
                    type: "bool"
                }
            ]
            onEdited: v => GlobalConfig.bar.entries = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Excluded screens")
            subtext: qsTr("Regexes of screens that get no bar")
            values: GlobalConfig.bar.excludedScreens
            onEdited: v => GlobalConfig.bar.excludedScreens = v
        }

        SectionHeader {
            text: qsTr("Workspaces")
        }

        NavRow {
            first: true
            last: true
            icon: "workspaces"
            label: qsTr("Workspaces")
            status: qsTr("Indicators, labels, window icons")
            onClicked: root.nState.openSubPage(18)
        }
    }
}
