import QtQuick
import QtQuick.Layouts
import Caelestia.Config

// A graph followed by its controls. While the section scrolls through the
// viewport the graph stays pinned to the top; the controls are clipped at
// its bottom edge instead of sliding underneath (surfaces are translucent,
// they would show through).
Item {
    id: root

    required property Item graph
    default property alias content: body.data

    // Viewport top in this item's coordinate space
    property real scrollY

    readonly property real spacing: Tokens.spacing.extraSmall / 2
    readonly property real shift: Math.max(0, Math.min(scrollY, body.implicitHeight))

    implicitHeight: graph.implicitHeight + spacing + body.implicitHeight

    Component.onCompleted: graph.parent = root

    Binding {
        target: root.graph
        property: "y"
        value: root.shift
    }

    Binding {
        target: root.graph
        property: "width"
        value: root.width
    }

    Binding {
        target: root.graph
        property: "height"
        value: root.graph.implicitHeight
    }

    Item {
        y: root.graph.implicitHeight + root.spacing + root.shift
        width: parent.width
        height: body.implicitHeight - root.shift
        clip: true

        ColumnLayout {
            id: body

            y: -root.shift
            width: parent.width
            spacing: root.spacing
        }
    }
}
