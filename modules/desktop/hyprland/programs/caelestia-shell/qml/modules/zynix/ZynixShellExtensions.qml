import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import qs.modules.zynix.games
import qs.modules.zynix.music
import qs.modules.zynix.tmux
import qs.modules.zynix.thunar

Scope {
    id: root

    MusicPicker {
        id: musicPicker
    }

    GamesPicker {
        id: gamesPicker
    }

    TmuxPicker {
        id: tmuxPicker
    }

    FileInfoDialog {
        id: fileInfoDialog
    }

    ChecksumDialog {
        id: checksumDialog
    }

    ExifDialog {
        id: exifDialog
    }

    MediaInfoDialog {
        id: mediaInfoDialog
    }

    IpcHandler {
        function open(): void {
            console.info(lc, "zynix.music.open");
            musicPicker.open();
        }

        target: "music"
    }

    IpcHandler {
        function open(): void {
            console.info(lc, "zynix.games.open");
            gamesPicker.open();
        }

        target: "games"
    }

    IpcHandler {
        function open(): void {
            console.info(lc, "zynix.tmux.open");
            tmuxPicker.open();
        }

        target: "tmux"
    }

    IpcHandler {
        function fileinfo(path: string): void {
            console.info(lc, `zynix.thunar.fileinfo path=${path}`);
            fileInfoDialog.open(path);
        }

        function checksum(path: string, algorithm: string): void {
            console.info(lc, `zynix.thunar.checksum path=${path} algorithm=${algorithm}`);
            checksumDialog.open(path, algorithm);
        }

        function exif(path: string): void {
            console.info(lc, `zynix.thunar.exif path=${path}`);
            exifDialog.open(path);
        }

        function mediainfo(path: string): void {
            console.info(lc, `zynix.thunar.mediainfo path=${path}`);
            mediaInfoDialog.open(path);
        }

        target: "thunar"
    }

    LoggingCategory {
        id: lc

        name: "zynix.qml.extensions"
        defaultLogLevel: LoggingCategory.Info
    }
}
