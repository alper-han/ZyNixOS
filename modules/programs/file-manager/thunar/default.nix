{
  lib,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../hosts/${host}/variables.nix) terminal;
  inherit (lib) getExe getExe';

  terminalPackage = pkgs.${terminal};
  terminalExe = getExe terminalPackage;
  open-terminal-here = pkgs.writeShellScriptBin "thunar-open-terminal-here" ''
    if [[ "$#" -lt 1 || ! -e "$1" ]]; then
      ${getExe pkgs.libnotify} "Open Terminal Here" "No valid path selected" -i dialog-error
      exit 1
    fi

    target="$1"
    if [[ ! -d "$target" ]]; then
      target="$(${getExe' pkgs.coreutils "dirname"} -- "$target")"
    fi

    if [[ ! -d "$target" ]]; then
      ${getExe pkgs.libnotify} "Open Terminal Here" "No valid directory selected" -i dialog-error
      exit 1
    fi

    exec ${getExe pkgs.uwsm} app -- ${terminalExe} --working-directory "$target"
  '';

  copy-path = pkgs.writeShellScriptBin "thunar-copy-path" ''
    if [[ "$#" -lt 1 ]]; then
      ${getExe pkgs.libnotify} "Copy Path" "No file or folder selected" -i dialog-error
      exit 1
    fi

    if ${getExe' pkgs.coreutils "printf"} '%s\n' "$@" | ${getExe' pkgs.wl-clipboard "wl-copy"} --type text/plain; then
      ${getExe pkgs.libnotify} "Copy Path" "Copied $# path(s) to clipboard" -i edit-copy
    else
      ${getExe pkgs.libnotify} "Clipboard Error" "Failed to copy path(s)" -i dialog-error
      exit 1
    fi
  '';

  generalActions = import ./actions/general.nix { inherit copy-path open-terminal-here; };
  checksumActions = import ./actions/checksum.nix { };
  fileinfoActions = import ./actions/fileinfo.nix { };

  backendHelpers = {
    thunar-backend-helper = pkgs.callPackage ./scripts/thunar-backend-helper.nix { };
  };
in
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages =
    (checksumActions.packages pkgs)
    ++ (fileinfoActions.packages pkgs)
    ++ [
      backendHelpers.thunar-backend-helper
      open-terminal-here
      copy-path
      pkgs.file-roller
    ];

  # System-wide defaults (/etc/xdg/mimeapps.list); ~/.config/mimeapps.list
  # stays writable for apps that register URL handlers at runtime.
  xdg.mime.defaultApplications =
    {
      "inode/directory" = "thunar.desktop";
    }
    // lib.genAttrs [
      "application/zip"
      "application/x-7z-compressed"
      "application/x-rar"
      "application/vnd.rar"
      "application/x-tar"
      "application/x-compressed-tar"
      "application/x-bzip2-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-zstd-compressed-tar"
    ] (_: "org.gnome.FileRoller.desktop");

  home-manager.sharedModules = [
    {
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          ${generalActions.xml}
          ${checksumActions.xml}
          ${fileinfoActions.xml}
        </actions>
      '';
    }
  ];
}
