{
  pkgs,
  host,
  resolveFlake,
  ...
}:
pkgs.writeShellScriptBin "rebuild" ''
  set -euo pipefail
  host="${host}"
  if [[ ! "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9_-]{0,61}[A-Za-z0-9])?$ ]]; then
    echo "Error: invalid host '$host'; it must match a configured host name." >&2
    exit 1
  fi

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  flake="$(${resolveFlake}/bin/resolve-flake)"
  if [[ ! -f "$flake/hosts/$host/configuration.nix" || ! -f "$flake/hosts/$host/hardware-configuration.nix" ]]; then
    echo "Error: host '$host' is missing configuration or hardware configuration under $flake/hosts." >&2
    exit 1
  fi

  # nh builds, shows the nvd package diff, elevates with sudo and activates.
  exec ${pkgs.nh}/bin/nh os switch "$flake" --hostname "$host"
''
