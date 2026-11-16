pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import Caelestia.Models
import qs.components
import qs.components.controls
import qs.services
import qs.utils

// Thumbnail tile for a recording or clip; click plays, hover shows file actions.
// Width is set by the grid; everything else derives from it.
Column {
    id: root

    required property FileSystemEntry entry
    // The entry turns null for a moment when its file is deleted
    readonly property string base: entry?.baseName ?? ""
    readonly property string path: entry?.path ?? ""
    readonly property string thumbDir: `${Paths.cache}/capture-thumbs`
    readonly property string thumbPath: `${thumbDir}/${root.base}.jpg`
    // [kind, date, app] from recording_<stamp>.ext / clip_<stamp>_<app>.ext
    readonly property var parts: {
        const m = root.base.match(/^(recording|clip)_(\d{4})(\d{2})(\d{2})_(\d{2})-(\d{2})-(\d{2})(?:_(.+))?/);
        if (!m)
            return ["", null, ""];
        return [m[1], new Date(m[2], m[3] - 1, m[4], m[5], m[6], m[7]), m[8] ?? ""];
    }
    property real duration
    property bool confirmDelete

    spacing: Tokens.spacing.small

    // Thumbnail and length are made once with ffmpeg and cached
    Process {
        id: thumbProc

        command: ["sh", "-c", `mkdir -p "$1" && ffmpeg -v error -y -ss 1 -i "$0" -frames:v 1 -vf scale=480:-2 "$1/$2.jpg"; ffprobe -v error -show_entries format=duration -of csv=p=0 "$0" > "$1/$2.dur"`, root.path, root.thumbDir, root.base]
        onExited: { // qmllint disable signal-handler-parameters
            thumb.source = "";
            thumb.source = `file://${root.thumbPath}`;
            durFile.reload();
        }
    }

    FileView {
        id: durFile

        path: `${root.thumbDir}/${root.base}.dur`
        printErrors: false
        onLoaded: root.duration = parseFloat(text()) || 0
    }

    StyledClippingRect {
        width: root.width
        height: Math.round(root.width * 9 / 16)
        radius: Tokens.rounding.medium
        color: Colours.tPalette.m3surfaceContainerHighest

        HoverHandler {
            id: hover
        }

        MaterialIcon {
            anchors.centerIn: parent
            visible: thumb.status !== Image.Ready
            text: root.parts[0] === "clip" ? "replay" : "movie"
            color: Colours.palette.m3outline
            fontStyle: Tokens.font.icon.large
        }

        Image {
            id: thumb

            property bool tried

            anchors.fill: parent
            source: `file://${root.thumbPath}`
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            onStatusChanged: {
                if (status === Image.Error && !tried && root.base) {
                    tried = true;
                    thumbProc.running = true;
                }
            }
        }

        StateLayer {
            onClicked: Quickshell.execDetached([...GlobalConfig.general.apps.playback, root.path])
        }

        StyledRect {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Tokens.padding.small
            visible: root.duration > 0
            implicitWidth: durText.implicitWidth + Tokens.padding.small * 2
            implicitHeight: durText.implicitHeight + Tokens.padding.extraSmall * 2
            radius: Tokens.rounding.small
            color: Qt.alpha(Colours.palette.m3surface, 0.8)

            StyledText {
                id: durText

                anchors.centerIn: parent
                text: Replay.formatDuration(Math.round(root.duration))
                color: Colours.palette.m3onSurface
                font: Tokens.font.label.small
            }
        }

        Row {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Tokens.padding.extraSmall
            opacity: hover.hovered || root.confirmDelete ? 1 : 0

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }

            IconButton {
                icon: "folder"
                type: IconButton.Tonal
                onClicked: Quickshell.execDetached([...GlobalConfig.general.apps.explorer, root.path])
            }

            // Copies the file itself, e.g. to paste it into a chat
            IconButton {
                icon: "content_copy"
                type: IconButton.Tonal
                onClicked: Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$0" | wl-copy --type text/uri-list', `file://${root.path}`])
            }

            // First click arms, second deletes
            IconButton {
                icon: root.confirmDelete ? "delete_forever" : "delete"
                type: IconButton.Tonal
                inactiveColour: root.confirmDelete ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
                label.color: root.confirmDelete ? Colours.palette.m3onError : Colours.palette.m3error
                onClicked: {
                    if (!root.confirmDelete) {
                        root.confirmDelete = true;
                        disarm.restart();
                        return;
                    }
                    CUtils.deleteFile(Qt.resolvedUrl(root.path));
                    Quickshell.execDetached(["rm", "-f", root.thumbPath, `${root.thumbDir}/${root.base}.dur`]);
                }
            }
        }
    }

    Column {
        x: Tokens.padding.extraSmall
        width: root.width - x

        StyledText {
            width: parent.width
            text: root.parts[2] || (root.parts[0] === "clip" ? qsTr("Clip") : root.parts[0] === "recording" ? qsTr("Recording") : (root.entry?.name ?? ""))
            font: Tokens.font.body.small
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width
            text: [root.parts[1] ? Qt.formatDateTime(root.parts[1], Qt.locale(), Locale.ShortFormat) : "", Replay.formatSize(root.entry?.size ?? 0)].filter(s => s).join(" · ")
            color: Colours.palette.m3outline
            font: Tokens.font.label.small
            elide: Text.ElideRight
        }
    }

    Timer {
        id: disarm

        interval: 3000
        onTriggered: root.confirmDelete = false
    }
}
