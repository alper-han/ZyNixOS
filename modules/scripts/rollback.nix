{ pkgs, ... }:
pkgs.writeShellScriptBin "rollback" ''
  set -euo pipefail
  resolve_flake() {
    local flake="''${NH_FLAKE:-}"
    if [[ -z "$flake" ]]; then
      if ! flake="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
        echo "Error: unable to resolve a flake from '$PWD'. Set NH_FLAKE or run inside a Git repository." >&2
        return 1
      fi
    fi
    if [[ "$flake" != /* ]]; then
      flake="$PWD/$flake"
    fi
    if [[ ! -f "$flake/flake.nix" ]]; then
      echo "Error: resolved flake '$flake' does not contain flake.nix. Set NH_FLAKE to a valid flake root." >&2
      return 1
    fi
    printf '%s\n' "$flake"
  }
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  NC='\033[0m'

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
    flake="$(resolve_flake)" || exit 1
    if [ ! -f "$flake/flake.nix" ]; then
      error "Canonical flake not found at $flake"
      exit 1
    fi
    (cd "$flake" && NH_FLAKE="$flake" nh os rollback -t "$generation")
  else
    sudo "/nix/var/nix/profiles/system-$generation-link/bin/switch-to-configuration" switch
  fi
''
