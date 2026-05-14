{ pkgs }:

pkgs.writeShellScript "caelestia-theme-post-hook" ''
  set -eu

  export PATH="${pkgs.gtk3}/bin:$PATH"

  scheme_colours="''${SCHEME_COLOURS:-}"
  if [ -z "$scheme_colours" ]; then
    scheme_colours='{}'
  fi

  primary_hex=$(
    ${pkgs.jq}/bin/jq -r '.primary // .surfaceTint // empty' <<< "$scheme_colours" 2>/dev/null \
      | ${pkgs.gnused}/bin/sed 's/^#//'
  )

  if [[ "$primary_hex" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    r=$((16#''${primary_hex:0:2}))
    g=$((16#''${primary_hex:2:2}))
    b=$((16#''${primary_hex:4:2}))

    max=$r
    [ "$g" -gt "$max" ] && max=$g
    [ "$b" -gt "$max" ] && max=$b
    min=$r
    [ "$g" -lt "$min" ] && min=$g
    [ "$b" -lt "$min" ] && min=$b
    delta=$((max - min))

    saturation=0
    if [ "$max" -gt 0 ]; then
      saturation=$((delta * 100 / max))
    fi

    hue=0
    if [ "$delta" -gt 0 ]; then
      if [ "$max" -eq "$r" ]; then
        hue=$((60 * (g - b) / delta))
        [ "$hue" -lt 0 ] && hue=$((hue + 360))
      elif [ "$max" -eq "$g" ]; then
        hue=$((60 * (b - r) / delta + 120))
      else
        hue=$((60 * (r - g) / delta + 240))
      fi
    fi

    color="grey"
    if [ "$saturation" -ge 12 ]; then
      if [ "$hue" -lt 13 ] || [ "$hue" -ge 345 ]; then
        color="red"
      elif [ "$hue" -lt 26 ]; then
        color="deeporange"
      elif [ "$hue" -lt 42 ]; then
        color="orange"
      elif [ "$hue" -lt 68 ]; then
        color="yellow"
      elif [ "$hue" -lt 155 ]; then
        color="green"
      elif [ "$hue" -lt 178 ]; then
        color="teal"
      elif [ "$hue" -lt 205 ]; then
        color="cyan"
      elif [ "$hue" -lt 242 ]; then
        if [ "$saturation" -lt 28 ]; then
          color="bluegrey"
        else
          color="blue"
        fi
      elif [ "$hue" -lt 270 ]; then
        color="indigo"
      elif [ "$hue" -lt 302 ]; then
        color="violet"
      else
        color="pink"
      fi
    fi

    icon_theme="Papirus-Dark"
    if [ "''${SCHEME_MODE:-dark}" = "light" ]; then
      icon_theme="Papirus"
    fi

    update_papirus_links() {
      theme_dir=""
      for icons_dir in "''${HOME:-}/.icons" "''${XDG_DATA_HOME:-''${HOME:-}/.local/share}/icons"; do
        if [ -f "$icons_dir/$icon_theme/index.theme" ]; then
          theme_dir="$icons_dir/$icon_theme"
          break
        fi
      done

      [ -n "$theme_dir" ] || return 1
      [ -w "$theme_dir/48x48/places/folder.svg" ] || return 1

      found=0
      for size in 22x22 24x24 32x32 48x48 64x64; do
        for prefix in "folder-$color" "user-$color"; do
          for file_path in "$theme_dir/$size/places/$prefix"{-*,}.svg; do
            [ -f "$file_path" ] || continue
            file_name="''${file_path##*/}"
            symlink_path="''${file_path/-$color/}"
            ${pkgs.coreutils}/bin/ln -sf "$file_name" "$symlink_path" || return 1
            found=1
          done
        done
      done

      [ "$found" -eq 1 ] || return 1
      folder_target="$(${pkgs.coreutils}/bin/readlink -f "$theme_dir/48x48/places/folder.svg" 2>/dev/null || true)"
      [ "''${folder_target##*/}" = "folder-$color.svg" ]
    }

    update_papirus_links || ${pkgs.papirus-folders}/bin/papirus-folders -o -C "$color" -t "$icon_theme" >/dev/null 2>&1 || true

    current_icon_theme="$(${pkgs.dconf}/bin/dconf read /org/gnome/desktop/interface/icon-theme 2>/dev/null || true)"
    if [ "$current_icon_theme" = "'$icon_theme'" ]; then
      refresh_icon_theme="Papirus-Dark"
      if [ "$icon_theme" = "Papirus-Dark" ]; then
        refresh_icon_theme="Papirus"
      fi
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'$refresh_icon_theme'" || true
    fi
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'$icon_theme'" || true
  fi

  portal_restart_state="''${XDG_RUNTIME_DIR:-/tmp}/caelestia-theme-portal-restart"
  portal_restart_token="$(${pkgs.coreutils}/bin/date +%s%N)"
  if printf '%s\n' "$portal_restart_token" > "$portal_restart_state" 2>/dev/null; then
    (
      ${pkgs.coreutils}/bin/sleep 2
      current_token="$(${pkgs.coreutils}/bin/cat "$portal_restart_state" 2>/dev/null || true)"
      if [ "$current_token" = "$portal_restart_token" ]; then
        ${pkgs.systemd}/bin/systemctl --user reset-failed \
          xdg-desktop-portal-gtk.service \
          xdg-desktop-portal.service >/dev/null 2>&1 || true
        ${pkgs.systemd}/bin/systemctl --user try-restart \
          xdg-desktop-portal-gtk.service \
          xdg-desktop-portal.service >/dev/null 2>&1 || true
      fi
    ) >/dev/null 2>&1 &
  fi
''
