import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    // Values must match the state names in modules/background/Background.qml
    readonly property list<MenuItem> positionItems: [
        MenuItem {
            text: "top-left"
        },
        MenuItem {
            text: "top-center"
        },
        MenuItem {
            text: "top-right"
        },
        MenuItem {
            text: "middle-left"
        },
        MenuItem {
            text: "middle-center"
        },
        MenuItem {
            text: "middle-right"
        },
        MenuItem {
            text: "bottom-left"
        },
        MenuItem {
            text: "bottom-center"
        },
        MenuItem {
            text: "bottom-right"
        }
    ]

    title: qsTr("Background")
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
            subtext: qsTr("Enable the background layer")
            checked: GlobalConfig.background.enabled
            onToggled: GlobalConfig.background.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Wallpaper")
            subtext: qsTr("Show the wallpaper on the background layer")
            checked: GlobalConfig.background.wallpaperEnabled
            onToggled: GlobalConfig.background.wallpaperEnabled = checked
        }

        SectionHeader {
            text: qsTr("Desktop clock")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("Show a clock on the desktop")
            checked: GlobalConfig.background.desktopClock.enabled
            onToggled: GlobalConfig.background.desktopClock.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Scale")
            subtext: qsTr("Size of the desktop clock")
            value: GlobalConfig.background.desktopClock.scale
            from: 0.2
            to: 3
            stepSize: 0.1
            onMoved: v => GlobalConfig.background.desktopClock.scale = v
        }

        SelectRow {
            Layout.fillWidth: true
            label: qsTr("Position")
            subtext: qsTr("Where the clock sits on the desktop")
            menuItems: root.positionItems
            active: root.positionItems.find(i => i.text === GlobalConfig.background.desktopClock.position) ?? null
            fallbackText: GlobalConfig.background.desktopClock.position
            onSelected: item => GlobalConfig.background.desktopClock.position = item.text
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Invert colours")
            subtext: qsTr("Invert the clock colours for readability")
            checked: GlobalConfig.background.desktopClock.invertColors
            onToggled: GlobalConfig.background.desktopClock.invertColors = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Background plate")
            subtext: qsTr("Draw a backing rectangle behind the clock")
            checked: GlobalConfig.background.desktopClock.background.enabled
            onToggled: GlobalConfig.background.desktopClock.background.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Plate opacity")
            subtext: qsTr("Opacity of the backing rectangle")
            value: GlobalConfig.background.desktopClock.background.opacity
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.background.desktopClock.background.opacity = v
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Plate blur")
            subtext: qsTr("Blur the wallpaper behind the backing rectangle")
            checked: GlobalConfig.background.desktopClock.background.blur
            onToggled: GlobalConfig.background.desktopClock.background.blur = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Shadow")
            subtext: qsTr("Draw a drop shadow behind the clock")
            checked: GlobalConfig.background.desktopClock.shadow.enabled
            onToggled: GlobalConfig.background.desktopClock.shadow.enabled = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Shadow opacity")
            subtext: qsTr("Opacity of the clock shadow")
            value: GlobalConfig.background.desktopClock.shadow.opacity
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.background.desktopClock.shadow.opacity = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Shadow blur")
            subtext: qsTr("Blur amount of the clock shadow")
            value: GlobalConfig.background.desktopClock.shadow.blur
            from: 0
            to: 1
            stepSize: 0.05
            onMoved: v => GlobalConfig.background.desktopClock.shadow.blur = v
        }

        SectionHeader {
            text: qsTr("Visualiser")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Enabled")
            subtext: qsTr("Show an audio visualiser on the desktop")
            checked: GlobalConfig.background.visualiser.enabled
            onToggled: GlobalConfig.background.visualiser.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Auto hide")
            subtext: qsTr("Hide the visualiser when no audio is playing")
            checked: GlobalConfig.background.visualiser.autoHide
            onToggled: GlobalConfig.background.visualiser.autoHide = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Blur")
            subtext: qsTr("Blur the wallpaper behind the visualiser")
            checked: GlobalConfig.background.visualiser.blur
            onToggled: GlobalConfig.background.visualiser.blur = checked
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Rounding")
            subtext: qsTr("Corner rounding of the visualiser bars")
            value: GlobalConfig.background.visualiser.rounding
            from: 0
            to: 3
            stepSize: 0.1
            onMoved: v => GlobalConfig.background.visualiser.rounding = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Spacing")
            subtext: qsTr("Spacing between the visualiser bars")
            value: GlobalConfig.background.visualiser.spacing
            from: 0
            to: 3
            stepSize: 0.1
            onMoved: v => GlobalConfig.background.visualiser.spacing = v
        }
    }
}
