{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe';
in
pkgs.writeShellScriptBin "driverinfo" ''
  set -euo pipefail
  ${getExe' pkgs.vulkan-tools "vulkaninfo"} | grep -i "deviceName\|driverID"
''
