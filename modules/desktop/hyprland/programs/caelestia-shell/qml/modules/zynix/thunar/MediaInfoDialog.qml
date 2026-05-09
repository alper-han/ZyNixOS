pragma ComponentBehavior: Bound

import QtQuick

ThunarResultDialog {
    function open(path: string): void {
        openCommand("mediainfo", path, "");
    }
}
