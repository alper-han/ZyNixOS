{ pkgs, defaultWallpaper, ... }:
pkgs.writeShellScriptBin "wallpaper" ''
  # Wait until the awww daemon is ready to accept commands.
  for _ in $(${pkgs.coreutils}/bin/seq 1 50); do
    if ${pkgs.awww}/bin/awww query &> /dev/null; then
      break
    fi
    ${pkgs.coreutils}/bin/sleep 0.1
  done

  # Restore wallpaper
  ${pkgs.awww}/bin/awww restore &> /dev/null

  # If there is no wallpaper then set the default
  if ! ${pkgs.awww}/bin/awww query | ${pkgs.gnugrep}/bin/grep -q "image:" &> /dev/null; then
    wallpaper_dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers"
    default_wallpaper="$wallpaper_dir/${defaultWallpaper}"

    if [ ! -d "$wallpaper_dir" ]; then
      exit 0
    fi

    if [ ! -f "$default_wallpaper" ]; then
      default_wallpaper="$(${pkgs.findutils}/bin/find "$wallpaper_dir" -maxdepth 1 -type f \( \
        -iname '*.gif' -o -iname '*.jpeg' -o -iname '*.jpg' -o \
        -iname '*.png' -o -iname '*.webp' \
      \) | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n 1)"
    fi

    if [ -n "$default_wallpaper" ]; then
      ${pkgs.awww}/bin/awww img "$default_wallpaper" --transition-step 255 --transition-duration 1 --transition-fps 60 --transition-type none
    fi
  fi
''
