import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("ChromaShell Extras")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            last: true
            text: qsTr("Shell enabled")
            subtext: qsTr("Master switch for the entire shell")
            checked: GlobalConfig.enabled
            onToggled: GlobalConfig.enabled = checked
        }

        SectionHeader {
            text: qsTr("Sections")
        }

        NavRow {
            first: true
            icon: "palette"
            text: qsTr("Appearance")
            subtext: qsTr("Scaling, transparency, fonts")
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "settings"
            text: qsTr("General")
            subtext: qsTr("Default apps, idle, battery")
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "wallpaper"
            text: qsTr("Background")
            subtext: Config.background.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "dock_to_bottom"
            text: qsTr("Bar")
            subtext: Config.bar.persistent ? qsTr("Always visible") : qsTr("Auto-hide")
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            icon: "rounded_corner"
            text: qsTr("Border")
            subtext: qsTr("Thickness, rounding, smoothing")
            onClicked: root.nState.openSubPage(5)
        }

        NavRow {
            icon: "dashboard"
            text: qsTr("Dashboard")
            subtext: Config.dashboard.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(6)
        }

        NavRow {
            icon: "apps"
            text: qsTr("Launcher")
            subtext: Config.launcher.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(7)
        }

        NavRow {
            icon: "lock"
            text: qsTr("Lock screen")
            subtext: qsTr("Fingerprint, notifications")
            onClicked: root.nState.openSubPage(8)
        }

        NavRow {
            icon: "settings_applications"
            text: qsTr("Nexus")
            subtext: qsTr("Settings app behaviour")
            onClicked: root.nState.openSubPage(9)
        }

        NavRow {
            icon: "notifications"
            text: qsTr("Notifications")
            subtext: qsTr("Timeouts, behaviour")
            onClicked: root.nState.openSubPage(10)
        }

        NavRow {
            icon: "tune"
            text: qsTr("OSD")
            subtext: Config.osd.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(11)
        }

        NavRow {
            icon: "build"
            text: qsTr("Services")
            subtext: qsTr("Weather, GPU, media, units")
            onClicked: root.nState.openSubPage(12)
        }

        NavRow {
            icon: "power_settings_new"
            text: qsTr("Session")
            subtext: Config.session.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(13)
        }

        NavRow {
            icon: "dock_to_right"
            text: qsTr("Sidebar")
            subtext: Config.sidebar.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(14)
        }

        NavRow {
            icon: "widgets"
            text: qsTr("Utilities")
            subtext: Config.utilities.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(15)
        }

        NavRow {
            icon: "gamepad"
            text: qsTr("Game mode")
            subtext: qsTr("Monitors while gaming")
            onClicked: root.nState.openSubPage(19)
        }

        NavRow {
            last: true
            icon: "folder"
            text: qsTr("Paths")
            subtext: qsTr("Wallpapers, lyrics, assets")
            onClicked: root.nState.openSubPage(16)
        }
    }
}
