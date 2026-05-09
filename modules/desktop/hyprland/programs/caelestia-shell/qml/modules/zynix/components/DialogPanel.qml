pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    default property alias content: contentColumn.data
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property real panelWidth: Tokens.sizes.launcher.itemWidth
    property real panelPadding: Tokens.padding.large
    property real contentSpacing: Tokens.spacing.large

    signal dismissed

    implicitWidth: root.panelWidth
    implicitHeight: contentColumn.implicitHeight + root.panelPadding * 2
    radius: Tokens.rounding.large
    color: Colours.palette.m3surfaceContainerHigh

    ColumnLayout {
        id: contentColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.panelPadding
        spacing: root.contentSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.normal
            visible: root.title.length > 0 || root.subtitle.length > 0 || root.icon.length > 0

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: root.icon.length > 0
                text: root.icon
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.extraLarge
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small / 2

                StyledText {
                    Layout.fillWidth: true
                    visible: root.title.length > 0
                    text: root.title
                    font.pointSize: Tokens.font.size.larger
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: root.subtitle.length > 0
                    text: root.subtitle
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WordWrap
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignTop
                icon: "close"
                type: IconButton.Text
                onClicked: root.dismissed()
            }
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.DefaultSpatial
        }
    }
}
