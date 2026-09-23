{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
  flake = "/home/${username}/ZyNixOS";
in
pkgs.writeShellScriptBin "rebuild" ''
  set -euo pipefail
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  flake="${flake}"

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  if [ ! -f "$flake/flake.nix" ]; then
    echo "Error: flake not found at $flake" >&2
    exit 1
  fi
  echo -e "''${GREEN}Flake: $flake''${NC}"
  echo -e "''${GREEN}Host: ${host}''${NC}"
  hardwareConfig="$flake/hosts/${host}/hardware-configuration.nix"
  if [ ! -f "$hardwareConfig" ]; then
    echo "Error: missing $hardwareConfig; generate it explicitly before rebuilding." >&2
    exit 1
  fi

  # Save current system for nvd comparison
  CURRENT_SYSTEM=$(readlink -f /run/current-system)

  sudo nixos-rebuild switch --flake "$flake#${host}"

  echo
  echo -e "''${GREEN}=== Package Changes ===''${NC}"
  ${pkgs.nvd}/bin/nvd diff "$CURRENT_SYSTEM" /run/current-system

  echo
''
