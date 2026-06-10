import QtQuick
import qs.modules.nexus.common

SliderRow {
    id: root

    property real from: 0
    property real to: 1
    property bool logScale: false
    property real paramValue
    property int decimals: 1
    property string unit: ""
    property bool signed: false
    property var formatValue: null

    signal changed(v: real)

    value: logScale ? Math.log(Math.max(paramValue, from) / from) / Math.log(to / from) : (paramValue - from) / (to - from)
    valueLabel: {
        if (formatValue)
            return formatValue(paramValue);
        const prefix = signed && paramValue >= 0 ? "+" : "";
        return prefix + paramValue.toFixed(decimals) + unit;
    }
    onMoved: v => changed(logScale ? from * Math.pow(to / from, v) : from + v * (to - from))
}
