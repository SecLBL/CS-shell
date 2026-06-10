pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

// Interactive EQ frequency response editor. Bands are draggable nodes
// (x = frequency on a log scale, y = gain), scrolling over a node adjusts
// its Q and double clicking toggles the band. The curve is the summed
// magnitude response of all enabled sections, computed from RBJ cookbook
// biquads — a visual approximation of the fil4 filters, not bit-exact.
ConnectedRect {
    id: root

    required property var eqState
    required property var bands
    property int selectedBand

    signal bandSelected(idx: int)
    signal paramChanged(symbol: string, value: real)
    signal enableToggled(idx: int)

    readonly property real gainRange: 18
    readonly property real fMin: 20
    readonly property real fMax: 20000
    readonly property real sampleRate: 48000
    readonly property bool eqEnabled: eqState.enable > 0.5

    function freqToX(f: real): real {
        return plot.width * Math.log(Math.max(f, fMin) / fMin) / Math.log(fMax / fMin);
    }

    function xToFreq(x: real): real {
        return fMin * Math.pow(fMax / fMin, Math.max(0, Math.min(1, x / plot.width)));
    }

    function gainToY(g: real): real {
        return plot.height / 2 * (1 - g / gainRange);
    }

    function yToGain(y: real): real {
        return (1 - 2 * y / plot.height) * gainRange;
    }

    // RBJ cookbook biquad coefficients for one section
    function sectionCoeffs(kind: string, f0: real, q: real, gainDb: real): var {
        const w0 = 2 * Math.PI * Math.max(f0, 1) / sampleRate;
        const cosw = Math.cos(w0);
        const sinw = Math.sin(w0);
        const A = Math.pow(10, gainDb / 40);
        const alpha = sinw / (2 * Math.max(q, 0.05));
        const sqA = Math.sqrt(A);

        if (kind === "peak")
            return [1 + alpha * A, -2 * cosw, 1 - alpha * A, 1 + alpha / A, -2 * cosw, 1 - alpha / A];
        if (kind === "lowshelf")
            return [A * ((A + 1) - (A - 1) * cosw + 2 * sqA * alpha), 2 * A * ((A - 1) - (A + 1) * cosw), A * ((A + 1) - (A - 1) * cosw - 2 * sqA * alpha), (A + 1) + (A - 1) * cosw + 2 * sqA * alpha, -2 * ((A - 1) + (A + 1) * cosw), (A + 1) + (A - 1) * cosw - 2 * sqA * alpha];
        if (kind === "highshelf")
            return [A * ((A + 1) + (A - 1) * cosw + 2 * sqA * alpha), -2 * A * ((A - 1) + (A + 1) * cosw), A * ((A + 1) + (A - 1) * cosw - 2 * sqA * alpha), (A + 1) - (A - 1) * cosw + 2 * sqA * alpha, 2 * ((A - 1) - (A + 1) * cosw), (A + 1) - (A - 1) * cosw - 2 * sqA * alpha];
        if (kind === "hp")
            return [(1 + cosw) / 2, -(1 + cosw), (1 + cosw) / 2, 1 + alpha, -2 * cosw, 1 - alpha];
        // "lp"
        return [(1 - cosw) / 2, 1 - cosw, (1 - cosw) / 2, 1 + alpha, -2 * cosw, 1 - alpha];
    }

    // Magnitude in dB of a biquad at frequency f, evaluated in closed form
    function magDb(c: var, f: real): real {
        const w = 2 * Math.PI * f / sampleRate;
        const cosw = Math.cos(w);
        const cos2w = Math.cos(2 * w);
        const [b0, b1, b2, a0, a1, a2] = c;
        const num = b0 * b0 + b1 * b1 + b2 * b2 + 2 * (b0 * b1 + b1 * b2) * cosw + 2 * b0 * b2 * cos2w;
        const den = a0 * a0 + a1 * a1 + a2 * a2 + 2 * (a0 * a1 + a1 * a2) * cosw + 2 * a0 * a2 * cos2w;
        return 10 * Math.log10(Math.max(num, 1e-12) / Math.max(den, 1e-12));
    }

    readonly property var curvePoints: {
        const st = eqState;
        const w = plot.width;
        const h = plot.height;
        if (w <= 0 || h <= 0)
            return [];

        const sections = [];
        if (st.enable > 0.5) {
            for (const b of bands) {
                if (st[b.enableSym] > 0.5)
                    sections.push(sectionCoeffs(b.kind, st[b.freqSym], st[b.qSym], b.gainSym ? st[b.gainSym] : 0));
            }
        }
        const master = st.enable > 0.5 ? st.gain : 0;

        const pts = [];
        const n = 120;
        for (let i = 0; i <= n; i++) {
            const f = fMin * Math.pow(fMax / fMin, i / n);
            let db = master;
            for (const c of sections)
                db += magDb(c, f);
            pts.push(Qt.point(i / n * w, Math.max(0, Math.min(h, gainToY(db)))));
        }
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
    implicitHeight: 260

    Item {
        id: plot

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        anchors.leftMargin: Tokens.padding.largeIncreased
        anchors.rightMargin: Tokens.padding.largeIncreased

        // Gain grid lines
        Repeater {
            model: [-12, -6, 0, 6, 12]

            Rectangle {
                required property int modelData

                x: 0
                y: root.gainToY(modelData)
                width: plot.width
                height: 1
                color: Qt.alpha(Colours.palette.m3outlineVariant, modelData === 0 ? 0.8 : 0.35)

                StyledText {
                    anchors.left: parent.left
                    anchors.bottom: parent.top
                    text: (parent.modelData > 0 ? "+" : "") + parent.modelData
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }
            }
        }

        // Frequency grid lines
        Repeater {
            model: [{
                f: 100,
                t: "100"
            }, {
                f: 1000,
                t: "1k"
            }, {
                f: 10000,
                t: "10k"
            }]

            Rectangle {
                required property var modelData

                x: root.freqToX(modelData.f)
                y: 0
                width: 1
                height: plot.height
                color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)

                StyledText {
                    anchors.left: parent.right
                    anchors.leftMargin: Tokens.spacing.extraSmall
                    anchors.bottom: parent.bottom
                    text: parent.modelData.t + " Hz"
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }
            }
        }

        // Summed response curve
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            opacity: root.eqEnabled ? 1 : 0.4

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

            Behavior on opacity {
                Anim {}
            }
        }

        // Band nodes
        Repeater {
            model: root.bands.length

            Item {
                id: node

                required property int index
                readonly property var band: root.bands[index]
                readonly property bool isFilter: !band.gainSym
                readonly property bool bandEnabled: root.eqState[band.enableSym] > 0.5
                readonly property bool selected: root.selectedBand === index

                x: root.freqToX(root.eqState[band.freqSym]) - width / 2
                y: (isFilter ? root.gainToY(0) : root.gainToY(root.eqState[band.gainSym])) - height / 2
                width: Tokens.padding.large * 2
                height: Tokens.padding.large * 2
                z: selected ? 3 : 2

                StyledRect {
                    anchors.centerIn: parent
                    implicitWidth: node.selected ? 18 : 14
                    implicitHeight: implicitWidth
                    radius: Tokens.rounding.full
                    color: {
                        const base = node.isFilter ? Colours.palette.m3tertiary : Colours.palette.m3primary;
                        if (!node.bandEnabled)
                            return Qt.alpha(Colours.palette.m3outline, 0.5);
                        return node.selected ? base : Qt.alpha(base, 0.35);
                    }
                    border.width: 2
                    border.color: node.bandEnabled ? (node.isFilter ? Colours.palette.m3tertiary : Colours.palette.m3primary) : Colours.palette.m3outline

                    Behavior on implicitWidth {
                        Anim {
                            type: Anim.FastSpatial
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed: root.bandSelected(node.index)
                    onDoubleClicked: root.enableToggled(node.index)

                    onPositionChanged: e => {
                        if (!pressed)
                            return;
                        const p = mapToItem(plot, e.x, e.y);
                        const freq = Math.max(node.band.freqFrom, Math.min(node.band.freqTo, root.xToFreq(p.x)));
                        root.paramChanged(node.band.freqSym, Math.round(freq));
                        if (!node.isFilter) {
                            const gain = Math.max(-root.gainRange, Math.min(root.gainRange, root.yToGain(p.y)));
                            root.paramChanged(node.band.gainSym, Math.round(gain * 10) / 10);
                        }
                    }

                    onWheel: e => {
                        const factor = e.angleDelta.y > 0 ? 1.08 : 1 / 1.08;
                        const cur = Math.max(root.eqState[node.band.qSym], 0.05);
                        const q = Math.max(Math.max(node.band.qFrom, 0.05), Math.min(node.band.qTo, cur * factor));
                        root.paramChanged(node.band.qSym, Math.round(q * 100) / 100);
                    }
                }
            }
        }
    }
}
