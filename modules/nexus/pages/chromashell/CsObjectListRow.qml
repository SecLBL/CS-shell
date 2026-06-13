pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

ConnectedRect {
    id: root

    property string label
    property string subtext
    property var values: []
    // Field descriptors: { key, label, type: "string"|"bool"|"int"|"real"|"json"|"select", options?, from?, to?, step? }
    property var fields: []
    property var defaultEntry: ({})
    property bool reorderable
    property string titleKey
    property int expandedIndex: -1

    signal edited(values: var)

    function copyValues(): var {
        return (root.values ?? []).map(e => (typeof e === "object" && e !== null) ? Object.assign({}, e) : e);
    }

    function entryTitle(index: int): string {
        const e = root.values[index];
        if (typeof e !== "object" || e === null)
            return String(e);
        const t = root.titleKey ? e[root.titleKey] : "";
        return t ? String(t) : qsTr("Entry %1").arg(index + 1);
    }

    function move(from: int, to: int): void {
        const xs = root.copyValues();
        const [e] = xs.splice(from, 1);
        xs.splice(to, 0, e);
        if (root.expandedIndex === from)
            root.expandedIndex = to;
        else if (root.expandedIndex === to)
            root.expandedIndex = from;
        root.edited(xs);
    }

    clip: false

    implicitHeight: col.implicitHeight + Tokens.padding.medium * 2

    ColumnLayout {
        id: col

        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        anchors.leftMargin: Tokens.padding.largeIncreased
        anchors.rightMargin: Tokens.padding.largeIncreased
        spacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.label
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: root.subtext
                    text: root.subtext
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                    elide: Text.ElideRight
                }
            }

            IconButton {
                icon: "add"
                type: IconButton.Tonal
                onClicked: {
                    const xs = root.copyValues();
                    xs.push(Object.assign({}, root.defaultEntry));
                    root.expandedIndex = xs.length - 1;
                    root.edited(xs);
                }
            }
        }

        StyledText {
            visible: !root.values || root.values.length === 0
            text: qsTr("No entries")
            color: Colours.palette.m3outline
            font: Tokens.font.label.small
        }

        Repeater {
            model: root.values?.length ?? 0

            StyledRect {
                id: card

                required property int index
                readonly property var entry: root.values[card.index]
                readonly property bool expanded: root.expandedIndex === card.index

                function setField(key: string, val: var): void {
                    const xs = root.copyValues();
                    xs[card.index][key] = val;
                    root.edited(xs);
                }

                Layout.fillWidth: true
                implicitHeight: cardCol.implicitHeight + Tokens.padding.small * 2
                radius: Tokens.rounding.medium
                color: Colours.tPalette.m3surfaceContainerHigh
                clip: false
                z: card.expanded ? 1 : 0

                ColumnLayout {
                    id: cardCol

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.small
                    anchors.leftMargin: Tokens.padding.medium
                    anchors.rightMargin: Tokens.padding.medium
                    spacing: Tokens.spacing.small

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.small

                        StyledText {
                            Layout.fillWidth: true
                            text: root.entryTitle(card.index)
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        IconButton {
                            visible: root.reorderable
                            enabled: card.index > 0
                            icon: "arrow_upward"
                            type: IconButton.Text
                            onClicked: root.move(card.index, card.index - 1)
                        }

                        IconButton {
                            visible: root.reorderable
                            enabled: card.index < root.values.length - 1
                            icon: "arrow_downward"
                            type: IconButton.Text
                            onClicked: root.move(card.index, card.index + 1)
                        }

                        IconButton {
                            icon: "delete"
                            type: IconButton.Text
                            onClicked: {
                                const xs = root.copyValues();
                                xs.splice(card.index, 1);
                                root.expandedIndex = -1;
                                root.edited(xs);
                            }
                        }

                        IconButton {
                            icon: card.expanded ? "expand_less" : "expand_more"
                            type: IconButton.Text
                            onClicked: root.expandedIndex = card.expanded ? -1 : card.index
                        }
                    }

                    Repeater {
                        model: card.expanded ? root.fields : []

                        RowLayout {
                            id: fieldRow

                            required property var modelData
                            readonly property var fieldValue: card.entry?.[modelData.key]
                            readonly property bool isText: modelData.type === "string" || modelData.type === "json"

                            Layout.fillWidth: true
                            spacing: Tokens.spacing.medium

                            StyledText {
                                Layout.fillWidth: true
                                text: fieldRow.modelData.label
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.label.medium
                                elide: Text.ElideRight
                            }

                            StyledSwitch {
                                visible: fieldRow.modelData.type === "bool"
                                checked: fieldRow.fieldValue === true
                                onToggled: card.setField(fieldRow.modelData.key, checked)
                            }

                            CustomSpinBox {
                                visible: fieldRow.modelData.type === "int" || fieldRow.modelData.type === "real"
                                min: fieldRow.modelData.from ?? 0
                                max: fieldRow.modelData.to ?? 9999
                                step: fieldRow.modelData.step ?? 1
                                value: Number(fieldRow.fieldValue ?? 0)
                                onValueModified: v => card.setField(fieldRow.modelData.key, fieldRow.modelData.type === "int" ? Math.round(v) : v)
                            }

                            StyledInputField {
                                id: textField

                                readonly property string serialised: {
                                    if (fieldRow.modelData.type === "json")
                                        return fieldRow.fieldValue === undefined ? "" : JSON.stringify(fieldRow.fieldValue);
                                    return String(fieldRow.fieldValue ?? "");
                                }

                                visible: fieldRow.isText
                                Layout.preferredWidth: 220
                                horizontalAlignment: TextInput.AlignLeft

                                onEditingFinished: {
                                    if (text === serialised)
                                        return;
                                    if (fieldRow.modelData.type === "json") {
                                        try {
                                            card.setField(fieldRow.modelData.key, JSON.parse(text));
                                        } catch (e) {
                                            // Invalid JSON is reverted on focus loss
                                        }
                                    } else {
                                        card.setField(fieldRow.modelData.key, text);
                                    }
                                }

                                Binding {
                                    target: textField
                                    property: "text"
                                    value: textField.serialised
                                    when: !textField.hasFocus
                                }
                            }

                            Loader {
                                visible: fieldRow.modelData.type === "select"
                                active: visible

                                sourceComponent: SplitButton {
                                    id: sel

                                    type: SplitButton.Tonal
                                    fallbackText: String(fieldRow.fieldValue ?? "")
                                    active: menuItems.find(i => i.text === String(fieldRow.fieldValue ?? "")) ?? null
                                    menuItems: optVariants.instances
                                    stateLayer.onClicked: sel.expanded = !sel.expanded
                                    menu.onItemSelected: item => card.setField(fieldRow.modelData.key, item.text)

                                    Variants {
                                        id: optVariants

                                        model: fieldRow.modelData.options ?? []

                                        MenuItem {
                                            required property string modelData

                                            text: modelData
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
