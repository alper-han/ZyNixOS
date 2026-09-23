{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
  flake = "/home/${username}/ZyNixOS";
in
pkgs.writeShellScriptBin "rollback" ''
  set -euo pipefail
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  flake="${flake}"

  info() {
    echo -e "\n''${GREEN}$1''${NC}"
  }

  warn() {
    echo -e "''${YELLOW}$1''${NC}"
  }

  error() {
    echo -e "''${RED}Error: $1''${NC}" >&2
  }

  generation="''${1:-}"

  if [ -z "$generation" ]; then
    error "Please provide a generation number (Use list-gens)"
    exit 1
  fi

  if [[ ! "$generation" =~ ^[0-9]+$ ]]; then
    error "Generation must be a positive integer."
    exit 1
  fi

  if [ ! -d "/nix/var/nix/profiles/system-$generation-link" ]; then
    error "Generation '$generation' does not exist"
    exit 1
  fi

  echo -e "''${GREEN}Generation: $generation''${NC}"

  if command -v nh &>/dev/null; then
    if [ ! -f "$flake/flake.nix" ]; then
      error "Canonical flake not found at $flake"
      exit 1
    fi
    (cd "$flake" && nh os rollback -t "$generation")
  else
    sudo "/nix/var/nix/profiles/system-$generation-link/bin/switch-to-configuration" switch
  fi
''
