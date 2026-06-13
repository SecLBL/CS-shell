pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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

    signal edited(values: var)

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
                onClicked: root.edited([...(root.values ?? []), ""])
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

            RowLayout {
                id: entryRow

                required property int index

                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledInputField {
                    id: entryField

                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft

                    onEditingFinished: {
                        if (text === String(root.values[entryRow.index] ?? ""))
                            return;
                        const xs = [...root.values];
                        xs[entryRow.index] = text;
                        root.edited(xs);
                    }

                    Binding {
                        target: entryField
                        property: "text"
                        value: String(root.values[entryRow.index] ?? "")
                        when: !entryField.hasFocus
                    }
                }

                IconButton {
                    icon: "delete"
                    type: IconButton.Text
                    onClicked: {
                        const xs = [...root.values];
                        xs.splice(entryRow.index, 1);
                        root.edited(xs);
                    }
                }
            }
        }
    }
}
