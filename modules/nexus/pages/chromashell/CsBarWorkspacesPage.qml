import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    // Values checked in modules/bar/components/workspaces/Workspace.qml
    readonly property list<MenuItem> capitalisationItems: [
        MenuItem {
            text: "preserve"
        },
        MenuItem {
            text: "lower"
        },
        MenuItem {
            text: "upper"
        }
    ]

    title: qsTr("Workspaces")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Shown workspaces")
            subtext: qsTr("Workspaces visible in the bar")
            value: GlobalConfig.bar.workspaces.shown
            from: 1
            to: 20
            stepSize: 1
            onMoved: v => GlobalConfig.bar.workspaces.shown = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Max window icons")
            subtext: qsTr("Window icons shown per workspace")
            value: GlobalConfig.bar.workspaces.maxWindowIcons
            from: 0
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.bar.workspaces.maxWindowIcons = Math.round(v)
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Active indicator")
            subtext: qsTr("Highlight the active workspace")
            checked: GlobalConfig.bar.workspaces.activeIndicator
            onToggled: GlobalConfig.bar.workspaces.activeIndicator = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Occupied background")
            subtext: qsTr("Draw a background behind occupied workspaces")
            checked: GlobalConfig.bar.workspaces.occupiedBg
            onToggled: GlobalConfig.bar.workspaces.occupiedBg = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Show windows")
            subtext: qsTr("Show window icons in workspaces")
            checked: GlobalConfig.bar.workspaces.showWindows
            onToggled: GlobalConfig.bar.workspaces.showWindows = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Windows on special workspaces")
            subtext: qsTr("Show window icons on special workspaces")
            checked: GlobalConfig.bar.workspaces.showWindowsOnSpecialWorkspaces
            onToggled: GlobalConfig.bar.workspaces.showWindowsOnSpecialWorkspaces = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Active trail")
            subtext: qsTr("Draw a trail behind the active workspace indicator")
            checked: GlobalConfig.bar.workspaces.activeTrail
            onToggled: GlobalConfig.bar.workspaces.activeTrail = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Per-monitor workspaces")
            subtext: qsTr("Show each monitor's own workspaces")
            checked: GlobalConfig.bar.workspaces.perMonitorWorkspaces
            onToggled: GlobalConfig.bar.workspaces.perMonitorWorkspaces = checked
        }

        SectionHeader {
            text: qsTr("Labels")
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Label")
            subtext: qsTr("Label for empty workspaces")
            value: GlobalConfig.bar.workspaces.label
            onEdited: v => GlobalConfig.bar.workspaces.label = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Occupied label")
            subtext: qsTr("Label for occupied workspaces")
            value: GlobalConfig.bar.workspaces.occupiedLabel
            onEdited: v => GlobalConfig.bar.workspaces.occupiedLabel = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Active label")
            subtext: qsTr("Label for the active workspace")
            value: GlobalConfig.bar.workspaces.activeLabel
            onEdited: v => GlobalConfig.bar.workspaces.activeLabel = v
        }

        SelectRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Capitalisation")
            subtext: qsTr("Capitalisation of workspace names")
            menuItems: root.capitalisationItems
            active: root.capitalisationItems.find(i => i.text === GlobalConfig.bar.workspaces.capitalisation) ?? root.capitalisationItems[0]
            onSelected: item => GlobalConfig.bar.workspaces.capitalisation = item.text
        }

        SectionHeader {
            text: qsTr("Icons")
        }

        CsObjectListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Special workspace icons")
            subtext: qsTr("Match special workspaces by name or regex")
            values: GlobalConfig.bar.workspaces.specialWorkspaceIcons
            titleKey: "name"
            defaultEntry: ({
                    name: "",
                    icon: ""
                })
            fields: [
                {
                    key: "name",
                    label: qsTr("Name"),
                    type: "string"
                },
                {
                    key: "regex",
                    label: qsTr("Regex"),
                    type: "string"
                },
                {
                    key: "flags",
                    label: qsTr("Regex flags"),
                    type: "string"
                },
                {
                    key: "icon",
                    label: qsTr("Icon"),
                    type: "string"
                }
            ]
            onEdited: v => GlobalConfig.bar.workspaces.specialWorkspaceIcons = v
        }

        CsObjectListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Window icons")
            subtext: qsTr("Override window icons by class regex")
            values: GlobalConfig.bar.workspaces.windowIcons
            titleKey: "regex"
            defaultEntry: ({
                    regex: "",
                    icon: ""
                })
            fields: [
                {
                    key: "regex",
                    label: qsTr("Class regex"),
                    type: "string"
                },
                {
                    key: "icon",
                    label: qsTr("Icon"),
                    type: "string"
                },
                {
                    key: "flags",
                    label: qsTr("Regex flags"),
                    type: "string"
                }
            ]
            onEdited: v => GlobalConfig.bar.workspaces.windowIcons = v
        }
    }
}
