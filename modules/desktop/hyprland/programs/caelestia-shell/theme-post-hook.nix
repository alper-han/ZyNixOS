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

    color="blue"
    if [ "$b" -gt "$r" ] && [ "$b" -gt "$g" ]; then
      r_ratio=$((r * 100 / b))
      g_ratio=$((g * 100 / b))
      rg_diff=$((r > g ? r - g : g - r))
      if [ "$r_ratio" -gt 70 ] && [ "$g_ratio" -gt 70 ]; then
        if [ "$rg_diff" -lt 15 ]; then
          color="blue"
        elif [ "$r" -gt "$g" ]; then
          color="violet"
        else
          color="cyan"
        fi
      elif [ "$r_ratio" -gt 60 ] && [ "$r" -gt "$g" ]; then
        color="violet"
      elif [ "$g_ratio" -gt 60 ] && [ "$g" -gt "$r" ]; then
        color="cyan"
      fi
    elif [ "$r" -gt "$g" ] && [ "$r" -gt "$b" ]; then
      if [ "$g" -gt $((b + 30)) ]; then
        color="orange"
      elif [ "$b" -gt $((g + 20)) ]; then
        color="magenta"
      else
        color="red"
      fi
    elif [ "$g" -gt "$r" ] && [ "$g" -gt "$b" ]; then
      if [ "$b" -gt $((r + 30)) ]; then
        color="cyan"
      elif [ "$r" -gt $((b + 30)) ]; then
        color="yellow"
      else
        color="green"
      fi
    fi

    ${pkgs.papirus-folders}/bin/papirus-folders -o -C "$color" -t Papirus-Dark -u || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'" || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'" || true
  fi

  ${pkgs.systemd}/bin/systemctl --user restart \
    xdg-desktop-portal-gtk.service \
    xdg-desktop-portal.service || true
''
