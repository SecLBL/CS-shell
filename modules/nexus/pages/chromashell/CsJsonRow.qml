import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

ConnectedRect {
    id: root

    property alias label: label.text
    property string subtext
    property var value
    property real fieldWidth: 260
    property bool invalid

    readonly property string serialised: root.value === undefined ? "" : JSON.stringify(root.value)

    signal edited(value: var)

    implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        anchors.leftMargin: Tokens.padding.largeIncreased
        anchors.rightMargin: Tokens.padding.largeIncreased
        spacing: Tokens.spacing.medium

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                id: label

                Layout.fillWidth: true
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

            StyledText {
                Layout.fillWidth: true
                visible: root.invalid
                text: qsTr("Invalid JSON — not saved")
                color: Colours.palette.m3error
                font: Tokens.font.label.small
                elide: Text.ElideRight
            }
        }

        StyledInputField {
            id: field

            Layout.preferredWidth: root.fieldWidth
            horizontalAlignment: TextInput.AlignLeft

            onTextEdited: root.invalid = false

            onEditingFinished: {
                if (text === root.serialised)
                    return;
                try {
                    root.edited(JSON.parse(text));
                    root.invalid = false;
                } catch (e) {
                    root.invalid = true;
                }
            }

            Binding {
                target: field
                property: "text"
                value: root.serialised
                when: !field.hasFocus
            }
        }
    }
}
