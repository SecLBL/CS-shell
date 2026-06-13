pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> styleItems: [
        MenuItem {
            text: qsTr("Headline")
        },
        MenuItem {
            text: qsTr("Title")
        },
        MenuItem {
            text: qsTr("Body")
        },
        MenuItem {
            text: qsTr("Label")
        },
        MenuItem {
            text: qsTr("Mono")
        },
        MenuItem {
            text: qsTr("Icon")
        }
    ]
    property int styleIdx: 0
    readonly property var styleCfg: [GlobalConfig.appearance.font.headline, GlobalConfig.appearance.font.title, GlobalConfig.appearance.font.body, GlobalConfig.appearance.font.label, GlobalConfig.appearance.font.mono, GlobalConfig.appearance.font.icon][styleIdx]
    readonly property var variantModel: {
        const s = root.styleCfg;
        const m = [
            {
                name: qsTr("Large"),
                cfg: s.large
            },
            {
                name: qsTr("Medium"),
                cfg: s.medium
            },
            {
                name: qsTr("Small"),
                cfg: s.small
            }
        ];
        // Only the icon style has an extra large variant
        if (root.styleIdx === 5)
            m.push({
                name: qsTr("Extra large"),
                cfg: s.extraLarge
            });
        return m;
    }

    title: qsTr("Fonts")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Font scale")
            subtext: qsTr("Multiplier for all font sizes")
            value: GlobalConfig.appearance.font.scale
            from: 0.5
            to: 2
            stepSize: 0.05
            onMoved: v => GlobalConfig.appearance.font.scale = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            label: qsTr("Clock font")
            subtext: qsTr("Font family used for clocks")
            value: GlobalConfig.appearance.font.clock
            onEdited: v => GlobalConfig.appearance.font.clock = v
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Workspaces font")
            subtext: qsTr("Font family used for workspace labels")
            value: GlobalConfig.appearance.font.workspaces
            onEdited: v => GlobalConfig.appearance.font.workspaces = v
        }

        SectionHeader {
            text: qsTr("Style")
        }

        SelectRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Edited style")
            subtext: qsTr("Which text style the rows below configure")
            menuItems: root.styleItems
            active: root.styleItems[root.styleIdx]
            onSelected: item => root.styleIdx = root.styleItems.indexOf(item)
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Style family")
            subtext: qsTr("Default font family for this style")
            value: root.styleCfg.family
            onEdited: v => root.styleCfg.family = v
        }

        Repeater {
            model: root.variantModel

            ColumnLayout {
                id: variantCol

                required property var modelData

                Layout.fillWidth: true
                spacing: Tokens.spacing.extraSmall / 2

                SectionHeader {
                    text: variantCol.modelData.name
                }

                CsTextFieldRow {
                    Layout.fillWidth: true
                    first: true
                    label: qsTr("Family")
                    subtext: qsTr("Empty inherits the style family")
                    value: variantCol.modelData.cfg.family
                    onEdited: v => variantCol.modelData.cfg.family = v
                }

                StepperRow {
                    Layout.fillWidth: true
                    label: qsTr("Size")
                    subtext: qsTr("Point size")
                    value: variantCol.modelData.cfg.size
                    from: 6
                    to: 72
                    stepSize: 1
                    onMoved: v => variantCol.modelData.cfg.size = Math.round(v)
                }

                StepperRow {
                    Layout.fillWidth: true
                    label: qsTr("Weight")
                    subtext: qsTr("100 = thin, 400 = normal, 700 = bold")
                    value: variantCol.modelData.cfg.weight
                    from: 100
                    to: 900
                    stepSize: 50
                    onMoved: v => variantCol.modelData.cfg.weight = Math.round(v)
                }

                ToggleRow {
                    Layout.fillWidth: true
                    text: qsTr("Italic")
                    subtext: qsTr("Use the italic variant")
                    checked: variantCol.modelData.cfg.italic
                    onToggled: variantCol.modelData.cfg.italic = checked
                }

                CsJsonRow {
                    Layout.fillWidth: true
                    last: true
                    label: qsTr("Variable axes")
                    subtext: qsTr("JSON object of axis values, e.g. {\"ROND\": 25}")
                    value: variantCol.modelData.cfg.vaxes
                    onEdited: v => variantCol.modelData.cfg.vaxes = v
                }
            }
        }
    }
}
