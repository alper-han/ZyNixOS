{
  caelestiaShellJson,
  config,
  lib,
  pkgs,
}:

lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  mkdir -p -- "${config.xdg.configHome}/caelestia"
  mkdir -p -- "${config.xdg.configHome}/gtk-3.0" "${config.xdg.configHome}/gtk-4.0"
  mkdir -p -- "${config.xdg.dataHome}/icons"

  for icon_theme in Papirus Papirus-Dark; do
    target="${config.xdg.dataHome}/icons/$icon_theme"
    if [ -L "$target" ]; then
      rm -f -- "$target"
    fi
    if [ ! -e "$target/index.theme" ]; then
      rm -rf -- "$target"
      cp -a -- "${pkgs.papirus-icon-theme}/share/icons/$icon_theme" "$target"
      chmod -R u+rwX -- "$target"
    fi
  done

  for gtk_file in \
    "${config.xdg.configHome}/gtk-3.0/gtk.css" \
    "${config.xdg.configHome}/gtk-3.0/thunar.css" \
    "${config.xdg.configHome}/gtk-4.0/gtk.css" \
    "${config.xdg.configHome}/gtk-4.0/thunar.css"; do
    if [ -L "$gtk_file" ]; then
      rm -f -- "$gtk_file"
    fi
  done

  shell_json="${config.xdg.configHome}/caelestia/shell.json"
  if [ ! -e "$shell_json" ] && [ ! -L "$shell_json" ]; then
    install -m 0644 -- "${caelestiaShellJson}" "$shell_json"
  fi
''
