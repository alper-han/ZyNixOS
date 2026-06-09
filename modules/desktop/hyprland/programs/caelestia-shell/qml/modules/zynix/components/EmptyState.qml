pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    property string icon: "manage_search"
    property string title: qsTr("No results")
    property string subtitle: qsTr("Try searching for something else")

    spacing: Tokens.spacing.medium

    MaterialIcon {
        Layout.alignment: Qt.AlignVCenter
        text: root.icon
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.icon.extraLarge
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: Tokens.spacing.small / 2

        StyledText {
            text: root.title
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.title.medium
        }

        StyledText {
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.medium
        }
    }
}
