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
    ${pkgs.awww}/bin/awww img "${../../../themes/wallpapers/${defaultWallpaper}}" --transition-step 255 --transition-duration 1 --transition-fps 60 --transition-type none
  fi
''
