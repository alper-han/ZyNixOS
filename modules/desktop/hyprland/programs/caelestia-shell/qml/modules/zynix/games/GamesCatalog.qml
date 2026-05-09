pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import qs.modules.zynix.services

Scope {
    id: root

    property var games: []
    property bool loading: false
    property string errorText: ""

    signal refreshed

    readonly property list<string> listCommand: ["zynix-games-catalog"]

    function refresh(): void {
        root.loading = true;
        root.errorText = "";
        console.info(lc, "zynix.games.refresh");
        runner.run(root.listCommand);
    }

    function parseOutput(output: string): var {
        if (output.trim().length === 0)
            return [];

        try {
            const parsed = JSON.parse(output);
            if (!Array.isArray(parsed))
                return [];

            return parsed.map(game => ({
                "name": String(game.name ?? "Unknown Game"),
                "source": String(game.source ?? "Game"),
                "icon": root.materialIconFor(String(game.icon ?? ""), String(game.source ?? "")),
                "iconName": String(game.icon ?? ""),
                "iconPath": String(game.iconPath ?? ""),
                "command": Array.isArray(game.command) ? game.command.map(part => String(part)) : [],
                "search": `${game.name ?? ""} ${game.source ?? ""}`.toLowerCase()
            })).filter(game => game.command.length > 0);
        } catch (error) {
            root.errorText = String(error);
            return [];
        }
    }

    function materialIconFor(icon: string, source: string): string {
        const raw = `${icon} ${source}`.toLowerCase();
        if (raw.includes("steam"))
            return "sports_esports";
        if (raw.includes("lutris"))
            return "stadia_controller";
        if (raw.includes("heroic"))
            return "shield";
        if (raw.includes("bottle"))
            return "wine_bar";
        return "sports_esports";
    }

    CommandRunner {
        id: runner

        onFinished: (command, exitCode, output, error) => {
            root.loading = false;

            if (exitCode !== 0) {
                root.games = [];
                root.errorText = error.trim();
                console.warn(lc, `zynix.games.error exitCode=${exitCode} stderr=${root.errorText}`);
                root.refreshed();
                return;
            }

            root.games = root.parseOutput(output);
            if (root.games.length === 0)
                console.info(lc, "zynix.games.empty");
            else
                console.info(lc, `zynix.games.refresh count=${root.games.length}`);

            root.refreshed();
        }
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.games.catalog"
        defaultLogLevel: LoggingCategory.Info
    }
}
