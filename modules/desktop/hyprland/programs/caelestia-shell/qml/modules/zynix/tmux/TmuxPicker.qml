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
import qs.modules.zynix.tmux

Scope {
    id: root

    property bool shown: false
    property var filteredSessions: []
    property int currentIndex: -1

    signal closed

    function open(): void {
        root.shown = true;
        root.updateFilter("");
        tmuxSessions.refresh();
        console.info(lc, "zynix.tmux.picker.open");
    }

    function close(): void {
        if (!root.shown)
            return;

        root.shown = false;
        console.info(lc, "zynix.tmux.picker.close");
        root.closed();
    }

    function updateFilter(text: string): void {
        const needle = text.toLowerCase().trim();
        root.filteredSessions = tmuxSessions.sessions.filter(session => needle.length === 0 || session.search.includes(needle));
        root.currentIndex = root.filteredSessions.length > 0 ? 0 : -1;
    }

    function terminalCommand(session: var): var {
        return ["uwsm", "app", "--", ...GlobalConfig.general.apps.terminal, "--hold", "-e", "tmux", "attach", "-t", session.name];
    }

    function attachSession(session: var): void {
        if (!session)
            return;

        console.info(lc, `zynix.tmux.attach session=${session.name}`);
        Quickshell.execDetached(root.terminalCommand(session));
        root.close();
    }

    function activateCurrent(): void {
        if (root.currentIndex < 0 || root.currentIndex >= root.filteredSessions.length) {
            console.info(lc, "zynix.tmux.attach.empty");
            return;
        }

        root.attachSession(root.filteredSessions[root.currentIndex]);
    }

    TmuxSessions {
        id: tmuxSessions

        onRefreshed: root.updateFilter("")
    }

    Variants {
        model: Screens.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            name: "zynix-tmux-picker"
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
                title: qsTr("Tmux")
                subtitle: tmuxSessions.errorText.length > 0 ? qsTr("Unable to list sessions") : qsTr("Search active sessions")
                icon: "terminal"
                panelWidth: Math.min(Tokens.sizes.launcher.itemWidth, win.width - Tokens.padding.large * 2)
                onDismissed: root.close()

                SearchList {
                    id: search

                    Layout.fillWidth: true
                    placeholderText: qsTr("Search Tmux Sessions...")
                    emptyTitle: qsTr("No tmux sessions")
                    emptySubtitle: tmuxSessions.loading ? qsTr("Refreshing sessions") : (tmuxSessions.errorText.length > 0 ? tmuxSessions.errorText : qsTr("Start or attach from tmux first"))
                    emptyIcon: tmuxSessions.errorText.length > 0 ? "error" : "terminal_off"
                    model: root.filteredSessions
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

                        icon: "terminal"
                        title: modelData.name
                        subtitle: modelData.path
                        trailingText: qsTr("%1 windows").arg(modelData.windows)
                        interactive: true
                        onActivated: root.attachSession(modelData)

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

        name: "zynix.qml.tmux"
        defaultLogLevel: LoggingCategory.Info
    }
}
