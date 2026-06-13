import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> fullscreenItems: [
        MenuItem {
            text: "on"
        },
        MenuItem {
            text: "off"
        }
    ]

    title: qsTr("Notifications")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Expire")
            subtext: qsTr("Hide notification popups after a timeout")
            checked: GlobalConfig.notifs.expire
            onToggled: GlobalConfig.notifs.expire = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Action on click")
            subtext: qsTr("Trigger the default action when a notification is clicked")
            checked: GlobalConfig.notifs.actionOnClick
            onToggled: GlobalConfig.notifs.actionOnClick = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Open expanded")
            subtext: qsTr("Show notification groups expanded by default")
            checked: GlobalConfig.notifs.openExpanded
            onToggled: GlobalConfig.notifs.openExpanded = checked
        }

        SelectRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Fullscreen popups")
            subtext: qsTr("Show notification popups over fullscreen windows")
            menuItems: root.fullscreenItems
            active: root.fullscreenItems.find(i => i.text === GlobalConfig.notifs.fullscreen) ?? root.fullscreenItems[0]
            onSelected: item => GlobalConfig.notifs.fullscreen = item.text
        }

        SectionHeader {
            text: qsTr("Timing & thresholds")
        }

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Default expire timeout")
            subtext: qsTr("How long popups stay visible (ms)")
            value: GlobalConfig.notifs.defaultExpireTimeout
            from: 500
            to: 60000
            stepSize: 500
            onMoved: v => GlobalConfig.notifs.defaultExpireTimeout = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Fullscreen expire timeout")
            subtext: qsTr("How long popups stay visible over fullscreen windows (ms)")
            value: GlobalConfig.notifs.fullscreenExpireTimeout
            from: 500
            to: 60000
            stepSize: 500
            onMoved: v => GlobalConfig.notifs.fullscreenExpireTimeout = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Clear threshold")
            subtext: qsTr("Drag distance to dismiss a notification (fraction of width)")
            value: GlobalConfig.notifs.clearThreshold
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.notifs.clearThreshold = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Expand threshold")
            subtext: qsTr("Notification body length before it can be expanded")
            value: GlobalConfig.notifs.expandThreshold
            from: 0
            to: 100
            stepSize: 5
            onMoved: v => GlobalConfig.notifs.expandThreshold = Math.round(v)
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Group preview count")
            subtext: qsTr("Notifications shown in a collapsed group")
            value: GlobalConfig.notifs.groupPreviewNum
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.notifs.groupPreviewNum = Math.round(v)
        }
    }
}
