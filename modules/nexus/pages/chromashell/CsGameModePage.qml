pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property var conf: GlobalConfig.utilities.gameMode

    // [width, height, rate] of every mode a monitor offers at its current aspect ratio
    readonly property var modes: {
        const out = [];
        for (const m of Hypr.monitors.values) {
            const o = m.lastIpcObject;
            out.push(...(o.availableModes ?? []).map(s => s.match(/(\d+)x(\d+)@([\d.]+)/)).filter(a => a && a[1] * o.height === a[2] * o.width).map(a => [Number(a[1]), Number(a[2]), Math.round(a[3])]));
        }
        return out;
    }

    readonly property list<MenuItem> modeItems: [
        MenuItem {
            text: qsTr("Unchanged")
            value: "off"
        },
        MenuItem {
            text: qsTr("Fixed resolution")
            value: "resolution"
        },
        MenuItem {
            text: qsTr("Percentage")
            value: "percent"
        }
    ]

    title: qsTr("Game mode")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Variants {
            id: monitorItems

            model: ["", ...Hypr.monitors.values.map(m => m.name)]

            MenuItem {
                required property string modelData

                text: modelData || qsTr("Focused monitor")
                value: modelData
            }
        }

        Variants {
            id: resolutionItems

            model: [...[...new Set([...root.modes].sort((a, b) => b[0] - a[0]).map(a => `${a[0]}x${a[1]}`))]]

            MenuItem {
                required property string modelData

                text: modelData
                value: modelData
            }
        }

        Variants {
            id: rateItems

            model: [0, ...[...new Set(root.modes.map(a => a[2]))].sort((a, b) => b - a)]

            MenuItem {
                required property int modelData

                text: modelData ? qsTr("%1 Hz").arg(modelData) : qsTr("Unchanged")
                value: modelData
            }
        }

        SectionHeader {
            text: qsTr("Monitors")
        }

        SelectRow {
            first: true
            label: qsTr("Main monitor")
            subtext: qsTr("Keeps its full resolution and refresh rate")
            menuItems: monitorItems.instances
            active: menuItems.find(i => i.value === root.conf.mainMonitor) ?? null
            fallbackText: root.conf.mainMonitor
            onSelected: item => root.conf.mainMonitor = item.value
        }

        SelectRow {
            label: qsTr("Other monitors: size")
            subtext: qsTr("Lower resolution frees video memory; the layout stays the same")
            menuItems: root.modeItems
            active: menuItems.find(i => i.value === root.conf.otherMode) ?? null
            fallbackText: root.conf.otherMode
            onSelected: item => root.conf.otherMode = item.value
        }

        SelectRow {
            visible: root.conf.otherMode === "resolution"
            label: qsTr("Resolution")
            subtext: qsTr("Other aspect ratios use their closest mode of the same height")
            menuItems: resolutionItems.instances
            active: menuItems.find(i => i.value === root.conf.otherResolution) ?? null
            fallbackText: root.conf.otherResolution
            onSelected: item => root.conf.otherResolution = item.value
        }

        StepperRow {
            Layout.fillWidth: true
            visible: root.conf.otherMode === "percent"
            label: qsTr("Percent of native resolution")
            subtext: qsTr("The closest mode each monitor supports is used")
            value: root.conf.otherScalePercent
            from: 25
            to: 100
            stepSize: 5
            onMoved: v => root.conf.otherScalePercent = Math.round(v)
        }

        SelectRow {
            last: true
            label: qsTr("Other monitors: refresh rate")
            subtext: qsTr("The closest rate each monitor supports is used")
            menuItems: rateItems.instances
            active: menuItems.find(i => i.value === root.conf.otherRefreshRate) ?? null
            fallbackText: qsTr("%1 Hz").arg(root.conf.otherRefreshRate)
            onSelected: item => root.conf.otherRefreshRate = item.value
        }

        SectionHeader {
            text: qsTr("Shell")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Hide background")
            subtext: qsTr("Removes wallpaper, visualiser and desktop clock")
            checked: root.conf.hideBackground
            onToggled: root.conf.hideBackground = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Slim shell")
            subtext: qsTr("Narrow bar and plain launcher instead of the fullscreen shell")
            checked: root.conf.slimShell
            onToggled: root.conf.slimShell = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Opaque shell")
            subtext: qsTr("Turns shell transparency off")
            checked: root.conf.opaqueShell
            onToggled: root.conf.opaqueShell = checked
        }

        SectionHeader {
            text: qsTr("Hyprland")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Disable effects")
            subtext: qsTr("Blur, shadows and animations; applied when game mode starts")
            checked: root.conf.disableEffects
            onToggled: root.conf.disableEffects = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("Compact layout")
            subtext: qsTr("No gaps or rounding, opaque windows; applied when game mode starts")
            checked: root.conf.compactLayout
            onToggled: root.conf.compactLayout = checked
        }

        SectionHeader {
            text: qsTr("Audio")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            last: true
            text: qsTr("Bypass noise reduction")
            subtext: qsTr("Turns DeepFilterNet off while gaming; the other plugins keep running")
            checked: root.conf.bypassNoiseReduction
            onToggled: root.conf.bypassNoiseReduction = checked
        }
    }
}
