pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common
import qs.modules.nexus.pages.chromashell

PageBase {
    id: root

    readonly property var conf: GlobalConfig.capture.autostart
    // App ids of open windows not covered by the list yet, offered as quick adds
    readonly property list<string> openApps: [...new Set(Hypr.toplevels.values.map(t => t.wayland?.appId ?? t.lastIpcObject?.class ?? "").filter(c => c && !Replay.appRegexes.some(r => r.test(c))))].sort()

    title: qsTr("Automatic start")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            first: true
            last: true
            text: qsTr("Start the replay buffer automatically")
            subtext: qsTr("Off pauses all rules, e.g. for benchmarks")
            checked: root.conf.enabled
            onToggled: root.conf.enabled = checked
        }

        SectionHeader {
            text: qsTr("When")
        }

        ToggleRow {
            first: true
            enabled: root.conf.enabled
            text: qsTr("The shell starts")
            checked: root.conf.onShellStart
            onToggled: root.conf.onShellStart = checked
        }

        ToggleRow {
            last: true
            enabled: root.conf.enabled
            text: qsTr("Game mode is on")
            checked: root.conf.onGameMode
            onToggled: root.conf.onGameMode = checked
        }

        SectionHeader {
            text: qsTr("Apps")
        }

        CsStringListRow {
            Layout.fillWidth: true
            first: true
            enabled: root.conf.enabled
            label: qsTr("Window classes (regex)")
            values: root.conf.apps
            onEdited: v => root.conf.apps = v
        }

        ToggleRow {
            last: true
            enabled: root.conf.enabled
            text: qsTr("Stop when they close")
            checked: root.conf.stopWithApps
            onToggled: root.conf.stopWithApps = checked
        }

        StyledText {
            visible: root.openApps.length > 0
            Layout.topMargin: Tokens.spacing.medium
            Layout.leftMargin: Tokens.padding.small
            text: qsTr("Open now")
            color: Colours.palette.m3outline
            font: Tokens.font.label.medium
        }

        Flow {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: root.openApps

                IconTextButton {
                    required property string modelData

                    icon: "add"
                    text: modelData
                    type: IconTextButton.Tonal
                    verticalPadding: Tokens.padding.extraSmall
                    onClicked: root.conf.apps = [...root.conf.apps, `^${modelData.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}$`]
                }
            }
        }
    }
}
