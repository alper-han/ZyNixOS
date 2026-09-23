{ pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  set -euo pipefail
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  flake="$HOME/ZyNixOS"
  host="$(hostname)"
  if [[ ! "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9_-]{0,61}[A-Za-z0-9])?$ ]]; then
    echo "Error: invalid hostname '$host'; it must match a configured host name." >&2
    exit 1
  fi

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  if [ ! -f "$flake/flake.nix" ]; then
    echo "Error: flake not found at $flake" >&2
    exit 1
  fi
  echo -e "''${GREEN}Flake: $flake''${NC}"
  echo -e "''${GREEN}Host: $host''${NC}"
  hardwareConfig="$flake/hosts/$host/hardware-configuration.nix"
  if [[ ! -f "$flake/hosts/$host/configuration.nix" || ! -f "$hardwareConfig" ]]; then
    echo "Error: host '$host' is missing configuration or hardware configuration under $flake/hosts." >&2
    exit 1
  fi

  # Save current system for nvd comparison
  CURRENT_SYSTEM=$(readlink -f /run/current-system)

  sudo nixos-rebuild switch --flake "$flake#$host"

  echo
  echo -e "''${GREEN}=== Package Changes ===''${NC}"
  ${pkgs.nvd}/bin/nvd diff "$CURRENT_SYSTEM" /run/current-system

  echo
''
