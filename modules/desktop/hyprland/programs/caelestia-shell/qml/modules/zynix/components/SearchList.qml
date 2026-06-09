pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services

Item {
    id: root

    default property alias listData: list.data
    property alias model: list.model
    property alias delegate: list.delegate
    property alias currentIndex: list.currentIndex
    property alias searchText: search.text
    property string placeholderText: qsTr("Search")
    property string emptyTitle: qsTr("No results")
    property string emptySubtitle: qsTr("Try searching for something else")
    property string emptyIcon: "manage_search"
    property real listWidth: Tokens.sizes.launcher.itemWidth
    property real maxListHeight: Tokens.sizes.launcher.itemHeight * 6
    property real rowSpacing: Tokens.spacing.small

    signal accepted

    readonly property ListView view: list
    readonly property StyledTextField searchField: search

    implicitWidth: root.listWidth
    implicitHeight: searchWrapper.implicitHeight + Tokens.spacing.medium + Math.max(listWrapper.implicitHeight, empty.implicitHeight)

    StyledRect {
        id: searchWrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Colours.palette.m3surfaceContainerHighest
        radius: Tokens.rounding.full
        implicitHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)

        MaterialIcon {
            id: searchIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Tokens.padding.large
            text: "search"
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledTextField {
            id: search

            anchors.left: searchIcon.right
            anchors.right: clearIcon.left
            anchors.leftMargin: Tokens.spacing.small
            anchors.rightMargin: Tokens.spacing.small
            topPadding: Tokens.padding.large
            bottomPadding: Tokens.padding.large
            placeholderText: root.placeholderText
            onAccepted: root.accepted()

            Keys.onUpPressed: list.decrementCurrentIndex()
            Keys.onDownPressed: list.incrementCurrentIndex()
        }

        MaterialIcon {
            id: clearIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Tokens.padding.large
            width: search.text ? implicitWidth : implicitWidth / 2
            opacity: search.text ? 1 : 0
            text: "close"
            color: Colours.palette.m3onSurfaceVariant

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: search.text ? Qt.PointingHandCursor : undefined
                onClicked: search.text = ""
            }

            Behavior on width {
                Anim {
                    type: Anim.StandardSmall
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.StandardSmall
                }
            }
        }
    }

    Item {
        id: listWrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: searchWrapper.bottom
        anchors.topMargin: Tokens.spacing.medium
        implicitHeight: Math.min(root.maxListHeight, list.contentHeight)
        clip: true
        visible: list.count > 0

        StyledListView {
            id: list

            anchors.fill: parent
            keyNavigationWraps: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: root.rowSpacing
        }
    }

    EmptyState {
        id: empty

        anchors.top: searchWrapper.bottom
        anchors.topMargin: Tokens.spacing.medium
        anchors.horizontalCenter: parent.horizontalCenter
        visible: list.count === 0
        icon: root.emptyIcon
        title: root.emptyTitle
        subtitle: root.emptySubtitle
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.5

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {}
        }
    }
}
