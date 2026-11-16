pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.Models

// Responsive grid of MediaTiles for a FileSystemModel; shows at most `limit` files
GridLayout {
    id: root

    required property FileSystemModel files
    property int limit: 1000
    readonly property real tileWidth: (width - columnSpacing * (columns - 1)) / columns

    Layout.fillWidth: true
    columns: Math.max(2, Math.floor(width / (Tokens.font.body.small.pointSize * 16)))
    columnSpacing: Tokens.spacing.medium
    rowSpacing: Tokens.spacing.large

    Repeater {
        model: root.files

        Loader {
            id: tile

            required property FileSystemEntry modelData
            required property int index

            Layout.preferredWidth: root.tileWidth
            Layout.alignment: Qt.AlignTop
            active: index < root.limit
            visible: active

            sourceComponent: MediaTile {
                entry: tile.modelData
            }
        }
    }
}
