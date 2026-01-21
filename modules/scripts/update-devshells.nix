{ pkgs, ... }:
pkgs.writeShellScriptBin "update-devshells" ''
  DEVSHELLS_DIR="''${1:-$HOME/ZyNixOS/dev-shells}"

  if [ ! -d "$DEVSHELLS_DIR" ]; then
    echo "Error: Directory $DEVSHELLS_DIR not found"
    exit 1
  fi

  echo "Updating all dev-shell flakes in $DEVSHELLS_DIR..."

  for template in "$DEVSHELLS_DIR"/*/; do
    if [ -f "$template/flake.nix" ]; then
      echo "Updating: $(basename "$template")"
      ${pkgs.nix}/bin/nix flake update --flake "$template"
    fi
  done

  echo "All dev-shells updated!"
''
