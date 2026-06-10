import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

// Smaller header for sub-groups that belong to a plugin section
// (visually subordinate to SectionHeader).
StyledText {
    Layout.fillWidth: true
    Layout.topMargin: Tokens.spacing.medium
    Layout.bottomMargin: Tokens.spacing.extraSmall
    Layout.leftMargin: Tokens.padding.small

    color: Colours.palette.m3outline
    font: Tokens.font.label.small
    elide: Text.ElideRight
}
