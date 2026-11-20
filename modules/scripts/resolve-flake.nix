{ pkgs, ... }:
# Prints the flake root: $NH_FLAKE when set, otherwise the current Git repository.
# Shared by rebuild, rollback and the sysup/dots shell aliases.
pkgs.writeShellScriptBin "resolve-flake" ''
  set -euo pipefail
  flake="''${NH_FLAKE:-}"
  if [[ -z "$flake" ]]; then
    if ! flake="$(${pkgs.git}/bin/git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
      echo "Error: unable to resolve a flake from '$PWD'. Set NH_FLAKE or run inside a Git repository." >&2
      exit 1
    fi
  fi
  if [[ "$flake" != /* ]]; then
    flake="$PWD/$flake"
  fi
  if [[ ! -f "$flake/flake.nix" ]]; then
    echo "Error: resolved flake '$flake' does not contain flake.nix. Set NH_FLAKE to a valid flake root." >&2
    exit 1
  fi
  printf '%s\n' "$flake"
''
