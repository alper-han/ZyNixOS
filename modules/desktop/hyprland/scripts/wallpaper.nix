{ pkgs, defaultWallpaper, ... }:
pkgs.writeShellScriptBin "wallpaper" ''
  # Restore wallpaper
  ${pkgs.swww}/bin/swww restore &> /dev/null

  # If there is no wallpaper then set the default
  if ! ${pkgs.swww}/bin/swww query | ${pkgs.gnugrep}/bin/grep -q "image:" &> /dev/null; then
    ${pkgs.swww}/bin/swww img "${../../../themes/wallpapers/${defaultWallpaper}}" --transition-step 255 --transition-duration 1 --transition-fps 60 --transition-type none
  fi
''
