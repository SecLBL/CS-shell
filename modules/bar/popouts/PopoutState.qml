import QtQuick

QtObject {
    property string currentName
    property bool hasCurrent
    property int previewWs // workspace shown by the "wspreview" popout

    signal detachRequested(mode: string)
}
