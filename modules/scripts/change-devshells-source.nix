{ pkgs, ... }:
pkgs.writeShellScriptBin "change-devshells-source" ''
  DEVSHELLS_DIR="''${1:-$HOME/ZyNixOS/dev-shells}"
  MODE="''${2:-flakehub}"  # "flakehub" or "github"

  if [ ! -d "$DEVSHELLS_DIR" ]; then
    echo "Error: Directory $DEVSHELLS_DIR not found"
    exit 1
  fi

  echo "Changing nixpkgs source in all dev-shells to: $MODE"

  for template in "$DEVSHELLS_DIR"/*/; do
    if [ -f "$template/flake.nix" ]; then
      echo "Processing: $(basename "$template")"

      if [ "$MODE" = "github" ]; then
        ${pkgs.gnused}/bin/sed -i -e 's|https://flakehub.com/f/NixOS/nixpkgs/0\.1.*\.tar.gz|github:nixos/nixpkgs/nixos-unstable|' "$template/flake.nix"
        ${pkgs.gnused}/bin/sed -i -e 's|https://flakehub.com/f/NixOS/nixpkgs/0\.1|github:nixos/nixpkgs/nixos-unstable|' "$template/flake.nix"
      else
        ${pkgs.gnused}/bin/sed -i -e 's|github:nixos/nixpkgs/nixos-unstable|https://flakehub.com/f/NixOS/nixpkgs/0.1|' "$template/flake.nix"
      fi
    fi
  done

  echo "Done! Source changed to: $MODE"
''
