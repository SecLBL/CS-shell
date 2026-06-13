import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Paths")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Wallpaper directory")
            subtext: qsTr("Where the wallpaper picker looks for images")
            value: GlobalConfig.paths.wallpaperDir
            onEdited: v => GlobalConfig.paths.wallpaperDir = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Lyrics directory")
            subtext: qsTr("Where local synced lyrics (.lrc) are stored")
            value: GlobalConfig.paths.lyricsDir
            onEdited: v => GlobalConfig.paths.lyricsDir = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Session GIF")
            subtext: qsTr("Image shown in the session menu (root:/ = shell root)")
            value: GlobalConfig.paths.sessionGif
            onEdited: v => GlobalConfig.paths.sessionGif = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Media GIF")
            subtext: qsTr("Image shown in the media player")
            value: GlobalConfig.paths.mediaGif
            onEdited: v => GlobalConfig.paths.mediaGif = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Cassette GIF")
            subtext: qsTr("Image shown in the cassette popout")
            value: GlobalConfig.paths.cassetteGif
            onEdited: v => GlobalConfig.paths.cassetteGif = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("No notifications image")
            subtext: qsTr("Image shown when the notification list is empty")
            value: GlobalConfig.paths.noNotifsPic
            onEdited: v => GlobalConfig.paths.noNotifsPic = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Lock screen no notifications image")
            subtext: qsTr("Image shown on the lock screen when there are no notifications")
            value: GlobalConfig.paths.lockNoNotifsPic
            onEdited: v => GlobalConfig.paths.lockNoNotifsPic = v
        }
    }
}
