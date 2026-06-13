import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Lock screen")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Recolour logo")
            subtext: qsTr("Tint the logo on the lock screen to match the scheme")
            checked: GlobalConfig.lock.recolourLogo
            onToggled: GlobalConfig.lock.recolourLogo = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Fingerprint unlock")
            subtext: qsTr("Allow unlocking with a fingerprint reader")
            checked: GlobalConfig.lock.enableFprint
            onToggled: GlobalConfig.lock.enableFprint = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Max fingerprint tries")
            subtext: qsTr("Attempts before fingerprint unlock is disabled")
            value: GlobalConfig.lock.maxFprintTries
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.lock.maxFprintTries = Math.round(v)
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Hide notifications")
            subtext: qsTr("Do not show notifications on the lock screen")
            checked: GlobalConfig.lock.hideNotifs
            onToggled: GlobalConfig.lock.hideNotifs = checked
        }
    }
}
