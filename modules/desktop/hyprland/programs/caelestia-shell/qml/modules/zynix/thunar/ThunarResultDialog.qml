pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.modules.zynix.components
import qs.modules.zynix.services

Scope {
    id: root

    property bool shown: false
    property bool loading: false
    property string dialogTitle: qsTr("Thunar")
    property string dialogSubtitle: ""
    property string dialogIcon: "description"
    property string commandName: "fileinfo"
    property string targetPath: ""
    property string algorithm: ""
    property string errorText: ""
    property var rows: []
    property int selectedIndex: rows.length > 0 ? 0 : -1

    signal closed

    function openCommand(command: string, path: string, algorithmName: string): void {
        root.commandName = command;
        root.targetPath = path;
        root.algorithm = algorithmName;
        root.errorText = "";
        root.rows = [];
        root.selectedIndex = -1;
        root.loading = true;
        root.configureTitle();
        root.shown = true;

        const args = ["thunar-backend-helper", command, path];
        if (command === "checksum")
            args.push(algorithmName);
        helperRunner.run(args);
    }

    function close(): void {
        if (!root.shown)
            return;

        root.shown = false;
        root.loading = false;
        root.closed();
    }

    function configureTitle(): void {
        if (root.commandName === "fileinfo") {
            root.dialogTitle = qsTr("File Info");
            root.dialogIcon = "draft";
            root.dialogSubtitle = root.targetPath;
        } else if (root.commandName === "checksum") {
            root.dialogTitle = qsTr("Checksum");
            root.dialogIcon = "tag";
            root.dialogSubtitle = root.algorithm.length > 0 ? `${root.algorithm} - ${root.targetPath}` : root.targetPath;
        } else if (root.commandName === "exif") {
            root.dialogTitle = qsTr("EXIF Info");
            root.dialogIcon = "photo_camera";
            root.dialogSubtitle = root.targetPath;
        } else if (root.commandName === "mediainfo") {
            root.dialogTitle = qsTr("Media Info");
            root.dialogIcon = "movie_info";
            root.dialogSubtitle = root.targetPath;
        }
    }

    function displayName(name: string): string {
        return name.replace(/_/g, " ").replace(/\b\w/g, match => match.toUpperCase());
    }

    function flattenFields(prefix: string, fields: var): var {
        const output = [];
        const keys = Object.keys(fields ?? {});
        for (const key of keys) {
            const value = fields[key];
            if (value !== null && typeof value === "object" && !Array.isArray(value)) {
                const childPrefix = prefix.length > 0 ? `${prefix} ${root.displayName(key)}` : root.displayName(key);
                output.push(...root.flattenFields(childPrefix, value));
            } else {
                const label = prefix.length > 0 ? `${prefix} - ${root.displayName(key)}` : root.displayName(key);
                output.push({"label": label, "value": String(value ?? "")});
            }
        }
        return output;
    }

    function rowsFromPayload(payload: var): var {
        if (payload.checksums)
            return Object.keys(payload.checksums).map(key => ({"label": key, "value": String(payload.checksums[key] ?? "")}));
        return root.flattenFields("", payload.fields ?? {});
    }

    function parseResult(output: string, error: string): var {
        const trimmedOutput = output.trim();
        const trimmedError = error.trim();
        if (trimmedOutput.length === 0)
            return {"ok": false, "error": {"message": trimmedError.length > 0 ? trimmedError : qsTr("No helper output")}};
        try {
            return JSON.parse(trimmedOutput);
        } catch (exception) {
            return {"ok": false, "error": {"message": qsTr("Could not parse helper output")}};
        }
    }

    function errorMessage(payload: var): string {
        const code = payload?.error?.code ?? "";
        const message = payload?.error?.message ?? qsTr("Unknown helper error");
        if ((code === "invalid-path" || code === "invalid-file") && (root.commandName === "fileinfo" || root.targetPath.length > 0))
            return "File does not exist";
        return message;
    }

    function allText(): string {
        if (root.errorText.length > 0)
            return root.errorText;
        return root.rows.map(row => `${row.label}: ${row.value}`).join("\n");
    }

    function selectedText(): string {
        if (root.selectedIndex < 0 || root.selectedIndex >= root.rows.length)
            return root.allText();
        const row = root.rows[root.selectedIndex];
        return String(row.value ?? "");
    }

    function copyText(text: string): void {
        if (text.length === 0)
            return;
        copyRunner.run(["thunar-backend-helper", "copy", text]);
    }

    CommandRunner {
        id: helperRunner

        onFinished: (command, exitCode, output, error) => {
            root.loading = false;
            const payload = root.parseResult(output, error);
            if (exitCode !== 0 || !payload.ok) {
                root.rows = [];
                root.selectedIndex = -1;
                root.errorText = root.errorMessage(payload);
                console.warn(lc, `zynix.thunar.${root.commandName}.error ${root.errorText}`);
                return;
            }

            root.errorText = "";
            root.rows = root.rowsFromPayload(payload);
            root.selectedIndex = root.rows.length > 0 ? 0 : -1;
            console.info(lc, `zynix.thunar.${root.commandName}.loaded rows=${root.rows.length}`);
        }
    }

    CommandRunner {
        id: copyRunner

        onFinished: (command, exitCode, output, error) => {
            if (exitCode === 0)
                console.info(lc, `zynix.thunar.copy.ok command=${root.commandName}`);
            else
                console.warn(lc, `zynix.thunar.copy.error ${error.trim()}`);
        }
    }

    Variants {
        model: Screens.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            name: `zynix-thunar-${root.commandName}`
            visible: root.shown
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            mask: root.shown ? null : emptyRegion

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Keys.onEscapePressed: root.close()

            Region {
                id: emptyRegion
            }

            StyledRect {
                anchors.fill: parent
                color: Colours.palette.m3scrim
                opacity: root.shown ? 0.45 : 0

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
                title: root.dialogTitle
                subtitle: root.dialogSubtitle
                icon: root.dialogIcon
                panelWidth: Math.min(Tokens.sizes.launcher.itemWidth * 1.35, win.width - Tokens.padding.large * 2)
                onDismissed: root.close()

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Math.min(win.height - Tokens.padding.large * 10, Math.max(Tokens.sizes.launcher.itemHeight * 4, contentStack.implicitHeight))
                    focus: true
                    Keys.onEscapePressed: root.close()
                    Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                    Keys.onDownPressed: root.selectedIndex = Math.min(root.rows.length - 1, root.selectedIndex + 1)
                    Component.onCompleted: forceActiveFocus()

                    ColumnLayout {
                        id: contentStack

                        anchors.fill: parent
                        spacing: Tokens.spacing.normal

                        EmptyState {
                            Layout.alignment: Qt.AlignHCenter
                            visible: root.loading
                            icon: "hourglass_top"
                            title: qsTr("Loading")
                            subtitle: qsTr("Reading metadata with thunar-backend-helper")
                        }

                        EmptyState {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !root.loading && root.errorText.length > 0
                            icon: "error"
                            title: qsTr("Unable to Load")
                            subtitle: root.errorText
                        }

                        ListView {
                            id: resultList

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: !root.loading && root.errorText.length === 0
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            keyNavigationWraps: true
                            currentIndex: root.selectedIndex
                            model: root.rows
                            onCurrentIndexChanged: root.selectedIndex = currentIndex

                            delegate: Item {
                                id: rowRoot

                                required property var modelData
                                required property int index

                                width: ListView.view.width
                                implicitHeight: Math.max(rowLayout.implicitHeight + Tokens.padding.normal * 2, Tokens.sizes.launcher.itemHeight)

                                StyledRect {
                                    anchors.fill: parent
                                    radius: Tokens.rounding.normal
                                    color: rowRoot.ListView.isCurrentItem ? Colours.palette.m3secondaryContainer : "transparent"
                                }

                                StateLayer {
                                    anchors.fill: parent
                                    radius: Tokens.rounding.normal
                                    onClicked: {
                                        root.selectedIndex = rowRoot.index;
                                        resultList.currentIndex = rowRoot.index;
                                    }
                                }

                                RowLayout {
                                    id: rowLayout

                                    anchors.fill: parent
                                    anchors.margins: Tokens.padding.normal
                                    spacing: Tokens.spacing.normal

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Tokens.spacing.small / 2

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: rowRoot.modelData.label
                                            color: Colours.palette.m3onSurfaceVariant
                                            font.pointSize: Tokens.font.size.small
                                            elide: Text.ElideRight
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: rowRoot.modelData.value
                                            font.family: Tokens.font.family.mono
                                            font.pointSize: Tokens.font.size.small
                                            wrapMode: Text.WrapAnywhere
                                            maximumLineCount: 6
                                            elide: Text.ElideRight
                                        }
                                    }

                                    IconButton {
                                        Layout.alignment: Qt.AlignTop
                                        icon: "content_copy"
                                        type: IconButton.Text
                                        onClicked: root.copyText(String(rowRoot.modelData.value ?? ""))
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    TextButton {
                        Layout.fillWidth: true
                        text: qsTr("Copy Selected")
                        enabled: !root.loading && (root.rows.length > 0 || root.errorText.length > 0)
                        inactiveColour: Colours.palette.m3secondaryContainer
                        inactiveOnColour: Colours.palette.m3onSecondaryContainer
                        onClicked: root.copyText(root.selectedText())
                    }

                    TextButton {
                        Layout.fillWidth: true
                        text: qsTr("Copy All")
                        enabled: !root.loading && (root.rows.length > 0 || root.errorText.length > 0)
                        inactiveColour: Colours.palette.m3primary
                        inactiveOnColour: Colours.palette.m3onPrimary
                        onClicked: root.copyText(root.allText())
                    }
                }
            }
        }
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.thunar.dialog"
        defaultLogLevel: LoggingCategory.Info
    }
}
