pragma Singleton

import Quickshell

Singleton {
    property alias open: props.open
    property alias posX: props.posX
    property alias posY: props.posY
    property alias screenName: props.screenName

    PersistentProperties {
        id: props

        property bool open
        property real posX: -1
        property real posY: -1
        property string screenName

        reloadableId: "cassetteState"
    }
}
