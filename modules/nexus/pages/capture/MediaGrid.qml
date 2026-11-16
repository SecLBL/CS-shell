pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.Models

// Grid of MediaTiles for a FileSystemModel; shows at most `limit` files.
// Sizes only flow from the width down (no layouts inside), so it can't loop on polish.
Flow {
    id: root

    required property FileSystemModel files
    property int limit: 1000
    readonly property int columns: Math.max(2, Math.floor(width / (Tokens.font.body.small.pointSize * 16)))
    readonly property real tileWidth: Math.floor((width - spacing * (columns - 1)) / columns)

    Layout.fillWidth: true
    Layout.preferredWidth: 0 // don't let the content width feed back into the page layout
    spacing: Tokens.spacing.medium

    Repeater {
        model: root.files

        MediaTile {
            required property FileSystemEntry modelData
            required property int index

            entry: modelData
            width: root.tileWidth
            visible: index < root.limit
        }
    }
}
