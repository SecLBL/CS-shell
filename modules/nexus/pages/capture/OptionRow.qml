pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components.controls
import qs.modules.nexus.common

// SelectRow fed with [value, label] pairs
SelectRow {
    id: root

    property var options: []
    property var current

    signal picked(value: var)

    menuItems: items.instances
    active: menuItems.find(i => i.value === root.current) ?? null
    fallbackText: String(root.current)
    onSelected: item => root.picked(item.value)

    Variants {
        id: items

        model: root.options

        MenuItem {
            required property var modelData

            text: modelData[1]
            value: modelData[0]
        }
    }
}
