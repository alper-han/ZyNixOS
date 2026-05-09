{ pkgs, ... }:
let
  catppuccinMocha = pkgs.fetchFromGitHub {
    owner = "orangci";
    repo = "walls-catppuccin-mocha";
    rev = "7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8";
    hash = "sha256-N+MZHSRcwOldS5Ai8B3YfKquKs9oeUW/GkV1iKM5+i8=";
  };

  jakoolitWallpaperBank = pkgs.fetchFromGitHub {
    owner = "JaKooLit";
    repo = "Wallpaper-Bank";
    rev = "c5e1780c29adca428dc4ca2d970bd1a6a09f18f3";
    hash = "sha256-hwxAgokCpCZwx/wnS2oWZNEQr76SWjzsi/Y+48sszE0=";
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

    {
      write_manifest_entries ${catppuccinMocha} catppuccin-mocha
      write_manifest_entries ${jakoolitWallpaperBank}/wallpapers jakoolit
    } | sort -t $'\t' -k2 > "$out/manifest.tsv"
  '';

  wallpaperSync = pkgs.writeShellApplication {
    name = "zynix-sync-wallpapers";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gnugrep
    ];
    text = ''
      set -euo pipefail

      destination="''${1:-$HOME/Pictures/Wallpapers}"
      manifest="${wallpaperBank}/manifest.tsv"
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/zynix"
      stamp_file="$state_dir/wallpaper-bank-manifest"

      if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$manifest" ]; then
        exit 0
      fi

      tmpdir="$(mktemp -d)"
      cleanup() {
        rm -rf "$tmpdir"
      }
      trap cleanup EXIT

      mkdir -p "$destination"
      mkdir -p "$state_dir"

      existing_hashes="$tmpdir/existing.sha256"
      : > "$existing_hashes"
      find "$destination" -type f \( \
        -iname '*.gif' -o -iname '*.jpeg' -o -iname '*.jpg' -o \
        -iname '*.png' -o -iname '*.webp' \
      \) -print0 | while IFS= read -r -d "" file; do
        sha256sum "$file" | cut -d' ' -f1 >> "$existing_hashes"
      done

      copy_wallpaper() {
        local source_file="$1"
        local rel="$2"
        local hash
        local base
        local target

        hash="$(sha256sum "$source_file" | cut -d' ' -f1)"
        if grep -qx "$hash" "$existing_hashes"; then
          return 0
        fi

        base="$(basename "$rel")"
        target="$destination/$base"
        if [ -e "$target" ]; then
          target="$destination/''${rel%%/*}-''${hash:0:12}-$base"
        fi

        install -m 0644 "$source_file" "$target"
        printf '%s\n' "$hash" >> "$existing_hashes"
      }

      while IFS=$'\t' read -r source_file rel; do
        [ -n "$source_file" ] || continue
        copy_wallpaper "$source_file" "$rel"
      done < "$manifest"

      printf '%s' "$manifest" > "$stamp_file"
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
