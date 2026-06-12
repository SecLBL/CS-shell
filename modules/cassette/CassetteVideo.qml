pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.components
import qs.services

// Live capture of the matched video player window
Item {
    id: root

    required property var client // HyprlandToplevel

    readonly property real targetWidth: 500
    readonly property real aspect: {
        const s = client?.lastIpcObject?.size;
        return (s && s[0] > 0 && s[1] > 0) ? s[0] / s[1] : 16 / 9;
    }

    implicitWidth: targetWidth
    implicitHeight: Math.max(200, Math.min(330, targetWidth / aspect))

    StyledClippingRect {
        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.tPalette.m3surfaceContainerHigh

        ScreencopyView {
            id: view

            anchors.centerIn: parent
            captureSource: root.client?.wayland ?? null // qmllint disable unresolved-type
            live: root.visible
            constraintSize.width: root.width
            constraintSize.height: root.height
        }

        Loader {
            anchors.centerIn: parent
            asynchronous: true
            active: !view.hasContent

            sourceComponent: ColumnLayout {
                spacing: Tokens.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "tv_off"
                    color: Colours.palette.m3outline
                    fontStyle: Tokens.font.icon.builders.large.scale(2).build()
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No video signal")
                    color: Colours.palette.m3outline
                    font: Tokens.font.body.medium
                }
            }
        }

        // Double-tap focuses the captured window; non-exclusive so dragging keeps working
        TapHandler {
            gesturePolicy: TapHandler.DragThreshold
            onDoubleTapped: {
                if (root.client?.address)
                    Hypr.dispatch(`hl.dsp.focus({window="address:0x${root.client.address}"})`);
            }
        }
    }
}
