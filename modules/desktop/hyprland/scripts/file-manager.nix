{
  lib,
  pkgs,
  terminal,
  ...
}:

let
  terminalExe = lib.getExe pkgs.${terminal};
in

pkgs.writeShellScriptBin "file-manager" ''
  manager="$1"

  case "$manager" in
    thunar|dolphin|nautilus|pcmanfm|nemo)
      exec "$manager"
      ;;
    yazi|lf|nnn|ranger|mc)
      exec ${terminalExe} --class "fileManager" -e "$manager"
      ;;
    *)
      echo "Unsupported file manager: $manager" >&2
      exit 1
      ;;
  esac
''
