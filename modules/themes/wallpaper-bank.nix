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

    write_manifest_entries ${alperHanWallpapers} wallpapers | sort -t $'\t' -k2,2 > "$out/manifest.tsv"
  '';

  wallpaperSync = pkgs.writeShellApplication {
    name = "zynix-sync-wallpapers";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
    ];
    text = ''
      set -euo pipefail

      destination="''${1:-$HOME/Pictures/Wallpapers}"
      manifest="${wallpaperBank}/manifest.tsv"
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/zynix"
      stamp_file="$state_dir/wallpaper-bank-rev"
      state_manifest="$state_dir/wallpaper-bank-files"
      current_manifest="$state_manifest.tmp"
      wallpaper_rev="${wallpaperRev}"

      if [ -f "$stamp_file" ] && [ "$(cat -- "$stamp_file")" = "$wallpaper_rev" ]; then
        exit 0
      fi

      mkdir -p -- "$destination" "$state_dir"
      cut -f2 -- "$manifest" > "$current_manifest"

      safe_relative_path() {
        case "$1" in
          ""|.|..|/*|../*|*/../*|*/..)
            return 1
            ;;
        esac
      }

      if [ -f "$state_manifest" ]; then
        while IFS= read -r rel; do
          safe_relative_path "$rel" || continue
          if ! grep -Fqx -- "$rel" "$current_manifest"; then
            rm -f -- "$destination/$rel"
          fi
        done < "$state_manifest"
      fi

      while IFS=$'\t' read -r source_file rel; do
        [ -n "$source_file" ] || continue
        safe_relative_path "$rel" || continue
        target="$destination/$rel"
        mkdir -p -- "$(dirname -- "$target")"
        install -m 0644 -- "$source_file" "$target"
      done < "$manifest"

      mv -f -- "$current_manifest" "$state_manifest"
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
