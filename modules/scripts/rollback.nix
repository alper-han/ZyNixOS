{ pkgs, resolveFlake, ... }:
pkgs.writeShellScriptBin "rollback" ''
  set -euo pipefail
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'

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

  flake="$(${resolveFlake}/bin/resolve-flake)"
  cd "$flake"
  NH_FLAKE="$flake" ${pkgs.nh}/bin/nh os rollback -t "$generation"
''
