pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.zynix.components
import qs.modules.zynix.games

Scope {
    id: root

    property bool shown: false
    property var filteredGames: []
    property int currentIndex: -1

    signal closed

    function open(): void {
        root.shown = true;
        root.updateFilter("");
        gamesCatalog.refresh();
        console.info(lc, "zynix.games.picker.open");
    }

    function close(): void {
        if (!root.shown)
            return;

        root.shown = false;
        console.info(lc, "zynix.games.picker.close");
        root.closed();
    }

    function updateFilter(text: string): void {
        const needle = text.toLowerCase().trim();
        root.filteredGames = gamesCatalog.games.filter(game => needle.length === 0 || game.search.includes(needle));
        root.currentIndex = root.filteredGames.length > 0 ? 0 : -1;
    }

    function launchGame(game: var): void {
        if (!game || game.command.length === 0)
            return;

        console.info(lc, `zynix.games.launch name=${game.name} source=${game.source}`);
        Quickshell.execDetached(game.command);
        root.close();
    }

    function activateCurrent(): void {
        if (root.currentIndex < 0 || root.currentIndex >= root.filteredGames.length) {
            console.info(lc, "zynix.games.launch.empty");
            return;
        }

        root.launchGame(root.filteredGames[root.currentIndex]);
    }

    GamesCatalog {
        id: gamesCatalog

        onRefreshed: root.updateFilter("")
    }

    Variants {
        model: Screens.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            name: "zynix-games-picker"
            visible: root.shown && Hypr.monitorFor(modelData) === Hypr.focusedMonitor
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: win.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            mask: win.visible ? null : emptyRegion

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Region {
                id: emptyRegion
            }

            StyledRect {
                anchors.fill: parent
                color: Colours.palette.m3scrim
                opacity: win.visible ? 0.35 : 0

                StateLayer {
                    anchors.fill: parent
                    onClicked: root.close()
                }

                Behavior on opacity {
                    Anim {}
                }
            }

            DialogPanel {
                id: panel

                anchors.centerIn: parent
                visible: root.shown
                title: qsTr("Games")
                subtitle: gamesCatalog.loading ? qsTr("Scanning game launchers") : qsTr("Search Steam and desktop games")
                icon: "sports_esports"
                panelWidth: Math.min(Tokens.sizes.launcher.itemWidth, win.width - Tokens.padding.large * 2)
                onDismissed: root.close()

                SearchList {
                    id: search

                    Layout.fillWidth: true
                    placeholderText: qsTr("Search Games...")
                    emptyTitle: qsTr("No games found")
                    emptySubtitle: gamesCatalog.errorText.length > 0 ? gamesCatalog.errorText : qsTr("Install Steam games or desktop game entries")
                    emptyIcon: gamesCatalog.errorText.length > 0 ? "error" : "sports_esports"
                    model: root.filteredGames
                    currentIndex: root.currentIndex
                    onCurrentIndexChanged: root.currentIndex = currentIndex
                    maxListHeight: Tokens.sizes.launcher.itemHeight * 8
                    onSearchTextChanged: root.updateFilter(searchText)
                    onAccepted: root.activateCurrent()

                    Keys.onEscapePressed: root.close()

                    Component.onCompleted: searchField.forceActiveFocus()

                    delegate: ActionRow {
                        required property var modelData
                        required property int index

                        width: search.view.width

                        icon: modelData.icon
                        iconName: modelData.iconName
                        iconPath: modelData.iconPath
                        title: modelData.name
                        subtitle: ""
                        trailingText: modelData.source === "Steam Library" ? qsTr("steam") : qsTr("open")
                        interactive: true
                        onActivated: root.launchGame(modelData)

                        StyledRect {
                            anchors.fill: parent
                            radius: Tokens.rounding.normal
                            color: parent.ListView.isCurrentItem ? Colours.palette.m3secondaryContainer : "transparent"
                            z: -1
                        }
                    }
                }
            }
        }
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.games"
        defaultLogLevel: LoggingCategory.Info
    }
}
