import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Session")
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
            subtext: qsTr("Enable the session menu")
            checked: GlobalConfig.session.enabled
            onToggled: GlobalConfig.session.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Vim keybinds")
            subtext: qsTr("Navigate the session menu with vim keys")
            checked: GlobalConfig.session.vimKeybinds
            onToggled: GlobalConfig.session.vimKeybinds = checked
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the session menu reveals")
            value: GlobalConfig.session.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.session.dragThreshold = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Icons")
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Logout")
            subtext: qsTr("Material icon for the logout button")
            value: GlobalConfig.session.icons.logout
            onEdited: v => GlobalConfig.session.icons.logout = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Shutdown")
            subtext: qsTr("Material icon for the shutdown button")
            value: GlobalConfig.session.icons.shutdown
            onEdited: v => GlobalConfig.session.icons.shutdown = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Hibernate")
            subtext: qsTr("Material icon for the hibernate button")
            value: GlobalConfig.session.icons.hibernate
            onEdited: v => GlobalConfig.session.icons.hibernate = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Reboot")
            subtext: qsTr("Material icon for the reboot button")
            value: GlobalConfig.session.icons.reboot
            onEdited: v => GlobalConfig.session.icons.reboot = v
        }

        SectionHeader {
            text: qsTr("Commands")
        }

        CsStringListRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Logout command")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.session.commands.logout
            onEdited: v => GlobalConfig.session.commands.logout = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Shutdown command")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.session.commands.shutdown
            onEdited: v => GlobalConfig.session.commands.shutdown = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Hibernate command")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.session.commands.hibernate
            onEdited: v => GlobalConfig.session.commands.hibernate = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Reboot command")
            subtext: qsTr("Command and arguments, one per entry")
            values: GlobalConfig.session.commands.reboot
            onEdited: v => GlobalConfig.session.commands.reboot = v
        }
    }
}
