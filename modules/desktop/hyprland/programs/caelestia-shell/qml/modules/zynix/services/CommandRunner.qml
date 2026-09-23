pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property list<Process> activeProcesses: []
    property int nextRequestId: 0

    signal finished(int requestId, list<string> command, int exitCode, string output, string error)

    function run(command: list<string>): int {
        const requestId = ++root.nextRequestId;
        const proc = commandProcessComponent.createObject(root);
        proc.command = command;
        proc.requestId = requestId;
        root.activeProcesses.push(proc);
        proc.exited.connect(code => {
            const output = proc.stdout.text ?? "";
            const error = proc.stderr.text ?? "";
            const index = root.activeProcesses.indexOf(proc);
            if (index >= 0)
                root.activeProcesses.splice(index, 1);
            if (!proc.cancelled)
                root.finished(requestId, command, code, output, error);
            proc.destroy();
        });
        proc.running = true;
        return requestId;
    }

    function cancel(requestId: int): void {
        for (const proc of root.activeProcesses) {
            if (proc.requestId === requestId && !proc.cancelled) {
                proc.cancelled = true;
                proc.terminate();
                return;
            }
        }
    }

    function cancelAll(): void {
        for (const proc of root.activeProcesses)
            root.cancel(proc.requestId);
    }

    Component {
        id: commandProcessComponent

        Process {
            property int requestId: 0
            property bool cancelled: false
            stdout: StdioCollector {}
            stderr: StdioCollector {}
        }
    }
}
