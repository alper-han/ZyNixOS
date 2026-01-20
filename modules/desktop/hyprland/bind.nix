# Hyprland Keybindings and Mouse Actions
# Usage: import ./bind.nix { inherit lib pkgs; }
{
  lib,
  pkgs,
}:
let
  inherit (lib) getExe getExe';

  # Import script modules
  keyboardswitch = pkgs.callPackage ./scripts/keyboardswitch.nix { };
  gamemode = pkgs.callPackage ./scripts/gamemode.nix { };
  clipmanager = pkgs.callPackage ./scripts/clipmanager.nix { };
  rofimusic = pkgs.callPackage ./scripts/rofimusic.nix { };
  screen-record = pkgs.callPackage ./scripts/screen-record.nix { };
  screenshot = pkgs.callPackage ./scripts/screenshot.nix { };
  zoom = pkgs.callPackage ./scripts/zoom.nix { };
  keybinds-yad = pkgs.callPackage ./scripts/keybinds-yad.nix { };
in
{
  "$mainMod" = "SUPER";

  # Repeatable binds (volume, brightness, resize)
  binde = [
    # Resize windows with arrow keys
    "$mainMod SHIFT, right, resizeactive, 30 0"
    "$mainMod SHIFT, left, resizeactive, -30 0"
    "$mainMod SHIFT, up, resizeactive, 0 -30"
    "$mainMod SHIFT, down, resizeactive, 0 30"

    # Resize windows with HJKL keys
    "$mainMod SHIFT, l, resizeactive, 30 0"
    "$mainMod SHIFT, h, resizeactive, -30 0"
    "$mainMod SHIFT, k, resizeactive, 0 -30"
    "$mainMod SHIFT, j, resizeactive, 0 30"

    # Brightness controls
    ",XF86MonBrightnessDown,exec,brightnessctl set 1%-"
    ",XF86MonBrightnessUp,exec,brightnessctl set +1%"

    # Volume controls
    ",XF86AudioLowerVolume,exec,pamixer -d 1"
    ",XF86AudioRaiseVolume,exec,pamixer -i 1"
  ];

  # Main keybindings
  bind = [
    # === Keybinds Help Menu ===
    "$mainMod, question, exec, ${getExe keybinds-yad}"
    "$mainMod, slash, exec, ${getExe keybinds-yad}"
    "$mainMod CTRL, K, exec, ${getExe keybinds-yad}"

    # === Night Mode ===
    "$mainMod, F9, exec, ${getExe pkgs.hyprsunset} --temperature 3500"
    "$mainMod, F10, exec, pkill hyprsunset"

    # === Window/Session Actions ===
    "$mainMod, Q, killactive"
    "ALT, F4, forcekillactive"
    "$mainMod, delete, exit"
    "$mainMod, W, togglefloating"
    "$mainMod SHIFT, G, togglegroup"
    "ALT, return, fullscreen"
    "$mainMod ALT, L, exec, hyprlock"
    "$mainMod, backspace, exec, pkill -x wlogout || wlogout -b 4"
    "$CONTROL, ESCAPE, exec, pkill waybar || waybar"

    # === Applications ===
    # Note: $term, $editor, $fileManager, $browser are defined in default.nix settings
    "$mainMod, Return, exec, $term"
    "$mainMod, T, exec, $term"
    "$mainMod, E, exec, $fileManager"
    "$mainMod, C, exec, $editor"
    "$mainMod, F, exec, $browser"
    "$mainMod SHIFT, S, exec, spotify"
    "$mainMod SHIFT, Y, exec, pear-desktop"
    "$CONTROL ALT, DELETE, exec, $term -e '${getExe pkgs.btop}'"
    "$mainMod CTRL, C, exec, hyprpicker --autocopy --format=hex"

    # === Launchers ===
    "$mainMod, A, exec, launcher drun"
    "$mainMod, SPACE, exec, launcher drun"
    "$mainMod SHIFT, W, exec, launcher wallpaper"
    "$mainMod, Z, exec, launcher emoji"
    "$mainMod SHIFT, T, exec, launcher tmux"
    "$mainMod, G, exec, launcher games"
    "$mainMod ALT, K, exec, ${getExe keyboardswitch}"
    "$mainMod SHIFT, N, exec, swaync-client -t -sw"
    "$mainMod SHIFT, Q, exec, swaync-client -t -sw"
    "$mainMod ALT, G, exec, ${getExe gamemode}"
    "$mainMod, V, exec, ${getExe clipmanager}"
    "$mainMod SHIFT, M, exec, ${getExe rofimusic}"

    # === Screenshot/Screencapture ===
    "$mainMod SHIFT, R, exec, ${getExe screen-record} a"
    "$mainMod CTRL, R, exec, ${getExe screen-record} m"
    "$mainMod, P, exec, ${getExe screenshot} s"
    "$mainMod CTRL, P, exec, ${getExe screenshot} sf"
    "$mainMod, print, exec, ${getExe screenshot} m"
    "$mainMod ALT, P, exec, ${getExe screenshot} p"

    # === Media Controls ===
    ",xf86Sleep, exec, systemctl suspend"
    ",XF86AudioMicMute,exec,pamixer --default-source -t"
    "$mainMod,M,exec,pamixer --default-source -t"
    ",XF86AudioMute,exec,pamixer -t"
    ",XF86AudioPlay,exec,playerctl play-pause"
    ",XF86AudioPause,exec,playerctl play-pause"
    ",xf86AudioNext,exec,playerctl next"
    ",xf86AudioPrev,exec,playerctl previous"

    # === Window Navigation ===
    "$mainMod, Tab, cyclenext"
    "$mainMod, Tab, bringactivetotop"

    # Workspace navigation (relative)
    "$mainMod CTRL, right, workspace, r+1"
    "$mainMod CTRL, left, workspace, r-1"
    "$mainMod CTRL, down, workspace, empty"

    # Move focus with arrow keys
    "$mainMod, left, movefocus, l"
    "$mainMod, right, movefocus, r"
    "$mainMod, up, movefocus, u"
    "$mainMod, down, movefocus, d"
    "ALT, Tab, movefocus, d"

    # Move focus with HJKL keys
    "$mainMod, h, movefocus, l"
    "$mainMod, l, movefocus, r"
    "$mainMod, k, movefocus, u"
    "$mainMod, j, movefocus, d"

    # === Mouse Side Buttons ===
    "$mainMod, mouse:276, workspace, 5"
    "$mainMod, mouse:275, workspace, 6"
    "$mainMod SHIFT, mouse:276, movetoworkspace, 5"
    "$mainMod SHIFT, mouse:275, movetoworkspace, 6"
    "$mainMod CTRL, mouse:276, movetoworkspacesilent, 5"
    "$mainMod CTRL, mouse:275, movetoworkspacesilent, 6"

    # === System ===
    "$mainMod, U, exec, $term -e rebuild"

    # Scroll through workspaces
    "$mainMod, mouse_down, workspace, e+1"
    "$mainMod, mouse_up, workspace, e-1"

    # Move window to relative workspace
    "$mainMod CTRL ALT, right, movetoworkspace, r+1"
    "$mainMod CTRL ALT, left, movetoworkspace, r-1"

    # Move window in current workspace (arrow keys)
    "$mainMod SHIFT $CONTROL, left, movewindow, l"
    "$mainMod SHIFT $CONTROL, right, movewindow, r"
    "$mainMod SHIFT $CONTROL, up, movewindow, u"
    "$mainMod SHIFT $CONTROL, down, movewindow, d"

    # Move window in current workspace (HJKL)
    "$mainMod SHIFT $CONTROL, H, movewindow, l"
    "$mainMod SHIFT $CONTROL, L, movewindow, r"
    "$mainMod SHIFT $CONTROL, K, movewindow, u"
    "$mainMod SHIFT $CONTROL, J, movewindow, d"

    # === Zoom ===
    "$mainMod CTRL, mouse_down, exec, ${getExe zoom} in"
    "$mainMod CTRL, mouse_up, exec, ${getExe zoom} out"

    # === Special Workspace (Scratchpad) ===
    "$mainMod CTRL, S, movetoworkspacesilent, special"
    "$mainMod ALT, S, movetoworkspacesilent, special"
    "$mainMod, S, togglespecialworkspace,"

    # === OBS Passthrough ===
    ",  F9, pass, class:^(com.obsproject.Studio)$"
    ", F10, pass, class:^(com.obsproject.Studio)$"
  ]
  # Workspace binds 1-10
  ++ (builtins.concatLists (
    builtins.genList (
      x:
      let
        ws =
          let
            c = (x + 1) / 10;
          in
          builtins.toString (x + 1 - (c * 10));
      in
      [
        "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
        "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        "$mainMod CTRL, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
      ]
    ) 10
  ))
  # Workspace binds 11-20 (ALT modifier)
  ++ (builtins.concatLists (
    builtins.genList (
      x:
      let
        workspaceNum = toString (x + 11);
        keyNum = if (x + 1) == 10 then "0" else toString (x + 1);
      in
      [
        "$mainMod ALT, ${keyNum}, workspace, ${workspaceNum}"
        "$mainMod SHIFT ALT, ${keyNum}, movetoworkspace, ${workspaceNum}"
        "$mainMod CTRL ALT, ${keyNum}, movetoworkspacesilent, ${workspaceNum}"
      ]
    ) 10
  ));

  # Mouse bindings
  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  # Bind settings
  binds = {
    workspace_back_and_forth = 0;
    pass_mouse_when_bound = 0;
    scroll_event_delay = 100;
  };
}
