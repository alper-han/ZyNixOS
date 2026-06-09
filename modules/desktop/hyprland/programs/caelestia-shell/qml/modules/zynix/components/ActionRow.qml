pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property string icon: ""
    property string iconName: ""
    property string iconPath: ""
    property string title: ""
    property string subtitle: ""
    property string trailingText: ""
    property bool interactive: true

    signal activated

    width: ListView.view?.width ?? implicitWidth
    implicitHeight: Math.max(Tokens.sizes.launcher.itemHeight, row.implicitHeight + Tokens.padding.extraSmall * 2)
    height: implicitHeight


    StateLayer {
        disabled: !root.interactive
        radius: Tokens.rounding.medium
        onClicked: root.activated()
    }

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.large
        anchors.rightMargin: Tokens.padding.large
        anchors.margins: Tokens.padding.extraSmall
        spacing: Tokens.spacing.medium

        Item {
            id: leadingIcon

            readonly property string themedIconPath: root.iconName.length > 0 ? Quickshell.iconPath(root.iconName) : ""

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Tokens.sizes.launcher.itemHeight * 0.72
            Layout.preferredHeight: Layout.preferredWidth
            visible: root.icon.length > 0 || root.iconName.length > 0 || root.iconPath.length > 0

            Image {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: root.iconPath.length > 0 ? Qt.resolvedUrl(`file://${root.iconPath}`) : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
                visible: root.iconPath.length > 0
            }

            Image {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: root.iconPath.length === 0 ? leadingIcon.themedIconPath : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
                visible: root.iconPath.length === 0 && leadingIcon.themedIconPath.length > 0
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: root.iconPath.length === 0 && leadingIcon.themedIconPath.length === 0 && root.icon.length > 0
                text: root.icon
                color: Colours.palette.m3primary
                font: Tokens.font.icon.extraLarge
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Tokens.spacing.small / 2

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font: Tokens.font.body.medium
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Colours.palette.m3outline
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            visible: root.trailingText.length > 0
            text: root.trailingText
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }
}
