{
  lib,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../hosts/${host}/variables.nix) bar terminal;
  inherit (lib) getExe getExe';
  isCaelestia = bar == "caelestia-shell";

  terminalPackage = pkgs.${terminal};
  terminalExe = getExe terminalPackage;
  open-terminal-here = pkgs.writeShellScriptBin "thunar-open-terminal-here" ''
    if [[ "$#" -lt 1 || ! -e "$1" ]]; then
      ${getExe pkgs.libnotify} "Open Terminal Here" "No valid path selected" -i dialog-error
      exit 1
    fi

    target="$1"
    if [[ ! -d "$target" ]]; then
      target="$(${getExe' pkgs.coreutils "dirname"} "$target")"
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

  peazip-action = pkgs.writeShellScriptBin "thunar-peazip" ''
    operation="$1"
    shift || true

    if [[ -z "$operation" || "$#" -lt 1 ]]; then
      ${getExe pkgs.libnotify} "PeaZip" "No operation or file selected" -i dialog-error
      exit 1
    fi

    case "$operation" in
      -add2archive|-add2zip|-add27z|-ext2here|-ext2newfolder|-ext2smart|-ext2browse|-ext2test|-add2convert)
        exec ${getExe pkgs.peazip} "$operation" "$@"
        ;;
      *)
        ${getExe pkgs.libnotify} "PeaZip" "Unsupported operation: $operation" -i dialog-error
        exit 1
        ;;
    esac
  '';

  # Import custom actions
  generalActions = import ./actions/general.nix { inherit copy-path open-terminal-here; };
  checksumActions = import ./actions/checksum.nix {
    inherit isCaelestia;
    checksumCommandFor = rofiFallbacks.checksumCommandFor;
  };
  fileinfoActions = import ./actions/fileinfo.nix {
    inherit isCaelestia;
    inherit (rofiFallbacks)
      exifCommandFallback
      fileInfoCommandFallback
      mediaInfoCommandFallback
      ;
  };
  peazipActions = import ./actions/peazip.nix { inherit peazip-action; };

  rofiFallbacks =
    if isCaelestia then
      {
        checksumCommandFor = _: throw "Rofi checksum fallback is disabled for caelestia-shell";
        fileInfoCommandFallback = throw "Rofi fileinfo fallback is disabled for caelestia-shell";
        exifCommandFallback = throw "Rofi exif fallback is disabled for caelestia-shell";
        mediaInfoCommandFallback = throw "Rofi mediainfo fallback is disabled for caelestia-shell";
        packages = [ ];
      }
    else
      let
        rofiTheme = "${../../../desktop/hyprland/programs/rofi/launchers/type-1}/style-6.rasi";
        checksum-rofi = pkgs.callPackage ./scripts/checksum-rofi.nix { inherit rofiTheme; };
        fileinfo-rofi = pkgs.callPackage ./scripts/fileinfo-rofi.nix { inherit rofiTheme; };
        exifinfo-rofi = pkgs.callPackage ./scripts/exifinfo-rofi.nix { inherit rofiTheme; };
        mediainfo-rofi = pkgs.callPackage ./scripts/mediainfo-rofi.nix { inherit rofiTheme; };
      in
      {
        checksumCommandFor = algorithm: "${checksum-rofi}/bin/checksum-rofi %f ${algorithm}";
        fileInfoCommandFallback = "${fileinfo-rofi}/bin/fileinfo-rofi %f";
        exifCommandFallback = "${exifinfo-rofi}/bin/exifinfo-rofi %f";
        mediaInfoCommandFallback = "${mediainfo-rofi}/bin/mediainfo-rofi %f";
        packages = [
          checksum-rofi
          fileinfo-rofi
          exifinfo-rofi
          mediainfo-rofi
        ];
      };

  backendHelpers = {
    thunar-backend-helper = pkgs.callPackage ./scripts/thunar-backend-helper.nix { };
  };
in
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages =
    (checksumActions.packages pkgs)
    ++ (fileinfoActions.packages pkgs)
    ++ (peazipActions.packages pkgs)
    ++ rofiFallbacks.packages
    ++ [
      backendHelpers.thunar-backend-helper
      open-terminal-here
      copy-path
      peazip-action
    ];

  # Thunar Custom Actions
  home-manager.sharedModules = [
    {
      # Custom Actions XML
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          ${generalActions.xml}
          ${checksumActions.xml}
          ${fileinfoActions.xml}
          ${peazipActions.xml}
        </actions>
      '';
    }
  ];
}
