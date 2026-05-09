{
  lib,
  pkgs,
  terminal,
  ...
}:
pkgs.writeShellScriptBin "launcher" ''
  # check if rofi is already running
  if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
  fi

  case $1 in
  drun)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-7.rasi"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-3.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Applications...';}listview{lines:9;}"

    rofi -show drun -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  window)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Windows...';}listview{lines:12;}"

    rofi -show window -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  file)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Files...';}listview{lines:8;}"

    rofi -show filebrowser -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  tmux)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Tmux Sessions...';}listview{lines:15;}"

    sessions=$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' 2>/dev/null |
      rofi -dmenu -i -theme-str "$r_override" -theme "$rofi_theme" | cut -d: -f1)
    if [[ $sessions ]]; then
      uwsm app -- ${terminal} --hold -e tmux attach -t "$sessions"
    fi
    ;;
  wallpaper)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/wallpaper-select.rasi"
    r_override="entry{placeholder:'Search Wallpapers...';}"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    # r_override="entry{placeholder:'Search Wallpapers...';}listview{lines:15;}"

    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zynix/wallpaper-thumbnails"
    WALLPAPER_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers"
    mkdir -p "$CACHE_DIR"

    if [ ! -d "$WALLPAPER_DIR" ]; then
      ${lib.getExe pkgs.libnotify} "Wallpaper directory not found" "$WALLPAPER_DIR"
      exit 1
    fi

    rofi_cmd() {
      rofi -dmenu \
        -i \
        -theme-str "$r_override" \
        -theme "$rofi_theme"
    }

    CHOICE=$(${lib.getExe' pkgs.findutils "find"} "''${WALLPAPER_DIR}" -maxdepth 1 -type f \( \
        -iname '*.gif' -o -iname '*.jpeg' -o -iname '*.jpg' -o \
        -iname '*.png' -o -iname '*.webp' \
      \) \
      | while read -r wallpaper; do \
          name="$(${lib.getExe' pkgs.coreutils "basename"} "$wallpaper")"; \
          thumb="''${CACHE_DIR}/$(${lib.getExe' pkgs.coreutils "sha256sum"} "$wallpaper" | ${lib.getExe' pkgs.coreutils "cut"} -d' ' -f1).jpg"; \
          if [ ! -f "$thumb" ]; then \
            ${lib.getExe pkgs.imagemagick} "$wallpaper[0]" -strip -gravity center -thumbnail "320x180^" -extent "320x180" "$thumb" >/dev/null 2>&1 || thumb="$wallpaper"; \
          fi; \
          echo -en "$name\x00icon\x1f$thumb\n"; \
        done \
      | rofi_cmd)
    [ -z "$CHOICE" ] && exit 0

    ${lib.getExe pkgs.awww} img "$WALLPAPER_DIR/$CHOICE" --transition-step 90 --transition-duration 1 --transition-fps 60 --transition-type wipe
    ;;
  emoji)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Emojis...';}listview{lines:15;}"

    rofi -modi emoji -show emoji -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  games)
    r_override="entry{placeholder:'Search Games...';}listview{lines:15;}"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-1/style-5.rasi"

    rofi -show games -modi games -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  help | --help | -h)
    echo "Usage: launcher [ACTION]"
    echo "Launch various rofi modes with custom themes and settings."
    echo ""
    echo "Actions:"
    echo "  drun         Launch application search mode"
    echo "  window       Switch between open windows"
    echo "  file         Browse and search files"
    echo "  tmux         Search active tmux sessions"
    echo "  wallpaper    Search and set wallpapers"
    echo "  emoji        Search and insert emojis"
    echo "  games        Launch games menu"
    echo "  help         Display this help message"
    echo "  --help       Same as 'help'"
    echo ""
    echo "If no action is specified, defaults to 'drun' mode."
    exit 0
    ;;
  *) exec "$0" drun ;;
  esac
''
