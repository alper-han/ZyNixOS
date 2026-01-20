{ pkgs, ... }:
pkgs.writeShellScriptBin "keyboardswitch" ''
  ${pkgs.hyprland}/bin/hyprctl switchxkblayout all next

  layMain=$(${pkgs.hyprland}/bin/hyprctl -j devices | ${pkgs.jq}/bin/jq '.keyboards' | ${pkgs.jq}/bin/jq '.[] | select (.main == true)' | ${pkgs.gawk}/bin/awk -F '"' '{if ($2=="active_keymap") print $4}')

  ${pkgs.libnotify}/bin/notify-send -a "System" -r 91190 -t 800 -i "$HOME/.config/hypr/icons/keyboard.svg" "''${layMain}"
''
