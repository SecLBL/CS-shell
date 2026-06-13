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
            label: qsTr("Appearance")
            status: qsTr("Scaling, transparency, fonts")
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "settings"
            label: qsTr("General")
            status: qsTr("Default apps, idle, battery")
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "wallpaper"
            label: qsTr("Background")
            status: Config.background.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "dock_to_bottom"
            label: qsTr("Bar")
            status: Config.bar.persistent ? qsTr("Always visible") : qsTr("Auto-hide")
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            icon: "rounded_corner"
            label: qsTr("Border")
            status: qsTr("Thickness, rounding, smoothing")
            onClicked: root.nState.openSubPage(5)
        }

        NavRow {
            icon: "dashboard"
            label: qsTr("Dashboard")
            status: Config.dashboard.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(6)
        }

        NavRow {
            icon: "apps"
            label: qsTr("Launcher")
            status: Config.launcher.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(7)
        }

        NavRow {
            icon: "lock"
            label: qsTr("Lock screen")
            status: qsTr("Fingerprint, notifications")
            onClicked: root.nState.openSubPage(8)
        }

        NavRow {
            icon: "settings_applications"
            label: qsTr("Nexus")
            status: qsTr("Settings app behaviour")
            onClicked: root.nState.openSubPage(9)
        }

        NavRow {
            icon: "notifications"
            label: qsTr("Notifications")
            status: qsTr("Timeouts, behaviour")
            onClicked: root.nState.openSubPage(10)
        }

        NavRow {
            icon: "tune"
            label: qsTr("OSD")
            status: Config.osd.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(11)
        }

        NavRow {
            icon: "build"
            label: qsTr("Services")
            status: qsTr("Weather, GPU, media, units")
            onClicked: root.nState.openSubPage(12)
        }

        NavRow {
            icon: "power_settings_new"
            label: qsTr("Session")
            status: Config.session.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(13)
        }

        NavRow {
            icon: "dock_to_right"
            label: qsTr("Sidebar")
            status: Config.sidebar.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(14)
        }

        NavRow {
            icon: "widgets"
            label: qsTr("Utilities")
            status: Config.utilities.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(15)
        }

        NavRow {
            last: true
            icon: "folder"
            label: qsTr("Paths")
            status: qsTr("Wallpapers, lyrics, assets")
            onClicked: root.nState.openSubPage(16)
        }
    }
}
