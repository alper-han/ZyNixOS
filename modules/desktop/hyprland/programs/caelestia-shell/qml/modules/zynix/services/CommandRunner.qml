pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property list<Process> activeProcesses: []

    signal finished(list<string> command, int exitCode, string output, string error)

    function run(command: list<string>): void {
        const proc = commandProcessComponent.createObject(root);
        proc.command = command;
        root.activeProcesses.push(proc);
        proc.exited.connect(code => {
            const output = proc.stdout.text ?? "";
            const error = proc.stderr.text ?? "";
            const index = root.activeProcesses.indexOf(proc);
            if (index >= 0)
                root.activeProcesses.splice(index, 1);
            root.finished(command, code, output, error);
            proc.destroy();
        });
        proc.running = true;
    }

    Component {
        id: commandProcessComponent

        Process {
            stdout: StdioCollector {}
            stderr: StdioCollector {}
        }
    }
}
