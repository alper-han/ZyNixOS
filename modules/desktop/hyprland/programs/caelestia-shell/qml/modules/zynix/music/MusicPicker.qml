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
import qs.modules.zynix.music

Scope {
    id: root

    property bool shown: false
    property var filteredSources: []
    property int currentIndex: -1

    signal closed

    function open(): void {
        root.updateFilter("");
        root.shown = true;
        console.info(lc, "zynix.music.picker.open");
    }

    function close(): void {
        if (!root.shown)
            return;

        root.shown = false;
        console.info(lc, "zynix.music.picker.close");
        root.closed();
    }

    function updateFilter(text: string): void {
        const needle = text.toLowerCase().trim();
        root.filteredSources = musicSources.sources.filter(source => needle.length === 0 || source.label.toLowerCase().includes(needle));
        root.currentIndex = root.filteredSources.length > 0 ? 0 : -1;
    }

    function launchSource(source: var): void {
        if (!source)
            return;

        console.info(lc, `zynix.music.launch label=${source.label} playlist=${source.playlist}`);
        Quickshell.execDetached(["pkill", "mpv"]);
        Quickshell.execDetached(source.command);
        root.close();
    }

    function activateCurrent(): void {
        if (root.currentIndex < 0 || root.currentIndex >= root.filteredSources.length) {
            console.info(lc, "zynix.music.launch.empty");
            return;
        }

        root.launchSource(root.filteredSources[root.currentIndex]);
    }

    function stopPlayback(): void {
        console.info(lc, "zynix.music.stop command=pkill mpv");
        Quickshell.execDetached(["pkill", "mpv"]);
        root.close();
    }

    MusicSources {
        id: musicSources
    }

    Variants {
        model: Screens.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            name: "zynix-music-picker"
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
                title: qsTr("Music")
                subtitle: qsTr("Search streams and playlists")
                icon: "music_note"
                panelWidth: Math.min(Tokens.sizes.launcher.itemWidth, win.width - Tokens.padding.large * 2)
                onDismissed: root.close()

                SearchList {
                    id: search

                    Layout.fillWidth: true
                    placeholderText: qsTr("Search Music...")
                    emptyTitle: qsTr("No music sources")
                    emptySubtitle: qsTr("Try another search")
                    emptyIcon: "music_off"
                    model: root.filteredSources
                    currentIndex: root.currentIndex
                    onCurrentIndexChanged: root.currentIndex = currentIndex
                    onSearchTextChanged: root.updateFilter(searchText)
                    onAccepted: root.activateCurrent()

                    Keys.onEscapePressed: root.close()

                    Component.onCompleted: searchField.forceActiveFocus()

                    delegate: ActionRow {
                        required property var modelData
                        required property int index

                        width: search.view.width

                        icon: modelData.playlist ? "queue_music" : "radio"
                        title: modelData.label
                        subtitle: modelData.url
                        trailingText: modelData.playlist ? qsTr("shuffle") : ""
                        interactive: true
                        onActivated: root.launchSource(modelData)

                        StyledRect {
                            anchors.fill: parent
                            radius: Tokens.rounding.medium
                            color: parent.ListView.isCurrentItem ? Colours.palette.m3secondaryContainer : "transparent"
                            z: -1
                        }
                    }
                }

                ActionRow {
                    Layout.fillWidth: true
                    icon: "stop_circle"
                    title: qsTr("Stop current playback")
                    subtitle: qsTr("Runs pkill mpv")
                    trailingText: qsTr("stop")
                    onActivated: root.stopPlayback()
                }
            }
        }
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.music"
        defaultLogLevel: LoggingCategory.Info
    }
}
