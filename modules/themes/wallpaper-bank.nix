{ pkgs, ... }:
let
  wallpaperRev = "5e88da74cec679ec351323c6af10e8f76e504fa7";

  alperHanWallpapers = pkgs.fetchFromGitHub {
    owner = "alper-han";
    repo = "wallpapers";
    rev = wallpaperRev;
    hash = "sha256-L8auW7zU0wdyMHx3tHxxVnonSq4nVoKpx4lx3WHzJEc=";
  };

  wallpaperBank = pkgs.runCommandLocal "zynix-wallpaper-bank" { } ''
    set -euo pipefail

    mkdir -p "$out"

    write_manifest_entries() {
      local source_dir="$1"
      local prefix="$2"

      find "$source_dir" -type f \( \
        -iname '*.gif' -o -iname '*.jpeg' -o -iname '*.jpg' -o \
        -iname '*.png' -o -iname '*.webp' \
      \) -print0 | while IFS= read -r -d "" file; do
        local rel="''${file#$source_dir/}"
        printf '%s\t%s/%s\n' "$file" "$prefix" "$rel"
      done
    }

    write_manifest_entries ${alperHanWallpapers} wallpapers > "$out/manifest.tsv"
  '';

  wallpaperSync = pkgs.writeShellApplication {
    name = "zynix-sync-wallpapers";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = ''
      set -euo pipefail

      destination="''${1:-$HOME/Pictures/Wallpapers}"
      manifest="${wallpaperBank}/manifest.tsv"
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/zynix"
      stamp_file="$state_dir/wallpaper-bank-rev"
      wallpaper_rev="${wallpaperRev}"

      if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$wallpaper_rev" ]; then
        exit 0
      fi

      mkdir -p "$destination"
      mkdir -p "$state_dir"

      copy_wallpaper() {
        local source_file="$1"
        local rel="$2"
        local base

        base="$(basename "$rel")"
        install -m 0644 "$source_file" "$destination/$base"
      }

      while IFS=$'\t' read -r source_file rel; do
        [ -n "$source_file" ] || continue
        copy_wallpaper "$source_file" "$rel"
      done < "$manifest"

      printf '%s' "$wallpaper_rev" > "$stamp_file"
    '';
  };
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        home.activation.zynixWallpaperBank = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${wallpaperSync}/bin/zynix-sync-wallpapers "${config.home.homeDirectory}/Pictures/Wallpapers"
        '';
      }
    )
  ];
}
