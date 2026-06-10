pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// Input/output transfer curve display for dynamics processors (gate,
// compressor). Both axes are level in dB (-80…0) with a dashed 1:1
// reference diagonal. The owner computes the curve in dB and handles the
// node semantics; this component only maps dB to pixels and forwards
// node interaction.
ConnectedRect {
    id: root

    property var curveDb: []
    property real nodeXDb
    property real nodeYDb
    property real hystXDb: NaN
    property bool active: true

    signal nodeMoved(xDb: real, yDb: real)
    signal nodeScrolled(up: bool)

    readonly property real dbMin: -80

    function dbToX(db: real): real {
        return plot.width * (db - dbMin) / -dbMin;
    }

    function xToDb(x: real): real {
        return dbMin - dbMin * Math.max(0, Math.min(1, x / plot.width));
    }

    function dbToY(db: real): real {
        return plot.height * (1 - (db - dbMin) / -dbMin);
    }

    function yToDb(y: real): real {
        return dbMin - dbMin * (1 - Math.max(0, Math.min(1, y / plot.height)));
    }

    readonly property var curvePoints: {
        const w = plot.width;
        const h = plot.height;
        if (w <= 0 || h <= 0)
            return [];
        const pts = [];
        for (const p of curveDb)
            pts.push(Qt.point(dbToX(p.x), Math.max(0, Math.min(h, dbToY(p.y)))));
        return pts;
    }

    readonly property var fillPoints: {
        const pts = [...curvePoints];
        if (pts.length === 0)
            return pts;
        pts.push(Qt.point(plot.width, plot.height));
        pts.push(Qt.point(0, plot.height));
        return pts;
    }

    first: true
    last: true
    implicitHeight: 240

    Item {
        id: plot

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        anchors.leftMargin: Tokens.padding.largeIncreased
        anchors.rightMargin: Tokens.padding.largeIncreased

        opacity: root.active ? 1 : 0.4

        Behavior on opacity {
            Anim {}
        }

        // Output level grid lines
        Repeater {
            model: [-60, -40, -20]

            Rectangle {
                required property int modelData

                x: 0
                y: root.dbToY(modelData)
                width: plot.width
                height: 1
                color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)

                StyledText {
                    anchors.left: parent.left
                    anchors.bottom: parent.top
                    text: parent.modelData
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }
            }
        }

        // Input level grid lines
        Repeater {
            model: [-60, -40, -20]

            Rectangle {
                required property int modelData

                x: root.dbToX(modelData)
                y: 0
                width: 1
                height: plot.height
                color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)

                StyledText {
                    anchors.left: parent.right
                    anchors.leftMargin: Tokens.spacing.extraSmall
                    anchors.bottom: parent.bottom
                    text: parent.modelData + " dB"
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }
            }
        }

        // 1:1 reference diagonal
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Qt.alpha(Colours.palette.m3outlineVariant, 0.8)
                strokeWidth: 1
                strokeStyle: ShapePath.DashLine
                dashPattern: [4, 4]
                fillColor: "transparent"
                startX: 0
                startY: plot.height

                PathLine {
                    x: plot.width
                    y: 0
                }
            }
        }

        // Hysteresis (close) threshold marker
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            visible: !isNaN(root.hystXDb)

            ShapePath {
                strokeColor: Colours.palette.m3tertiary
                strokeWidth: 1
                strokeStyle: ShapePath.DashLine
                dashPattern: [3, 3]
                fillColor: "transparent"
                startX: isNaN(root.hystXDb) ? 0 : root.dbToX(root.hystXDb)
                startY: 0

                PathLine {
                    x: isNaN(root.hystXDb) ? 0 : root.dbToX(root.hystXDb)
                    y: plot.height
                }
            }
        }

        // Transfer curve
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillColor: Qt.alpha(Colours.palette.m3primary, 0.12)

                PathPolyline {
                    path: root.fillPoints
                }
            }

            ShapePath {
                strokeColor: Colours.palette.m3primary
                strokeWidth: 2
                fillColor: "transparent"
                joinStyle: ShapePath.RoundJoin
                capStyle: ShapePath.RoundCap

                PathPolyline {
                    path: root.curvePoints
                }
            }
        }

        // Draggable node
        Item {
            id: node

            x: root.dbToX(root.nodeXDb) - width / 2
            y: Math.max(0, Math.min(plot.height, root.dbToY(root.nodeYDb))) - height / 2
            width: Tokens.padding.large * 2
            height: Tokens.padding.large * 2
            z: 2

            StyledRect {
                anchors.centerIn: parent
                implicitWidth: 16
                implicitHeight: 16
                radius: Tokens.rounding.full
                color: Qt.alpha(Colours.palette.m3primary, 0.35)
                border.width: 2
                border.color: Colours.palette.m3primary
            }

            MouseArea {
                anchors.fill: parent
                preventStealing: true
                cursorShape: Qt.PointingHandCursor

                onPositionChanged: e => {
                    if (!pressed)
                        return;
                    const p = mapToItem(plot, e.x, e.y);
                    root.nodeMoved(root.xToDb(p.x), root.yToDb(p.y));
                }

                onWheel: e => root.nodeScrolled(e.angleDelta.y > 0)
            }
        }
    }
}
