pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import qs.modules.zynix.services

Scope {
    id: root

    property var sessions: []
    property bool loading: false
    property string errorText: ""

    signal refreshed
    signal failed(string message)

    readonly property list<string> listCommand: ["tmux", "ls", "-F", "#{session_name}: #{session_path} (#{session_windows} windows)"]

    function refresh(): void {
        root.loading = true;
        root.errorText = "";
        console.info(lc, "zynix.tmux.refresh");
        runner.run(root.listCommand);
    }

    function parseOutput(output: string): var {
        return output.split("\n")
            .map(line => root.parseLine(line.trim()))
            .filter(session => session !== null);
    }

    function parseLine(line: string): var {
        if (line.length === 0)
            return null;

        const suffixMatch = line.match(/ \((\d+) windows\)$/);
        if (!suffixMatch)
            return null;

        const withoutSuffix = line.slice(0, suffixMatch.index);
        const separator = withoutSuffix.indexOf(": ");
        if (separator < 0)
            return null;

        const name = withoutSuffix.slice(0, separator);
        const path = withoutSuffix.slice(separator + 2);
        const windows = Number(suffixMatch[1]);
        return {
            "name": name,
            "path": path,
            "windows": windows,
            "display": line,
            "search": `${name} ${path} ${windows} windows`.toLowerCase()
        };
    }

    CommandRunner {
        id: runner

        onFinished: (command, exitCode, output, error) => {
            root.loading = false;

            if (exitCode !== 0) {
                root.sessions = [];
                root.errorText = error.trim();
                if (root.errorText.includes("no server running"))
                    console.info(lc, "zynix.tmux.noServer");
                else
                    console.warn(lc, `zynix.tmux.error exitCode=${exitCode} stderr=${root.errorText}`);
                console.info(lc, "zynix.tmux.empty");
                root.failed(root.errorText);
                root.refreshed();
                return;
            }

            root.sessions = root.parseOutput(output);
            if (root.sessions.length === 0)
                console.info(lc, "zynix.tmux.empty");
            else
                console.info(lc, `zynix.tmux.refresh count=${root.sessions.length}`);

            root.refreshed();
        }
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.tmux.sessions"
        defaultLogLevel: LoggingCategory.Info
    }
}
