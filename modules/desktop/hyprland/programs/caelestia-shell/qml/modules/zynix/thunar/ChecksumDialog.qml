pragma ComponentBehavior: Bound

import QtQuick

ThunarResultDialog {
    function open(path: string, algorithm: string): void {
        openCommand("checksum", path, algorithm);
    }
}
