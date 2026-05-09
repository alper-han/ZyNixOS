# Hyprland Keybindings and Mouse Actions
# Usage: import ./bind.nix { inherit lib pkgs host; }
{
  lib,
  pkgs,
  host,
}:
let
  inherit (lib) getExe;
  inherit (import ../../../hosts/${host}/variables.nix) bar;

  # Import script modules
  clipmanager = pkgs.callPackage ./scripts/clipmanager.nix { };
  keyboardswitch = pkgs.callPackage ./scripts/keyboardswitch.nix { };
  gamemode = pkgs.callPackage ./scripts/gamemode.nix { };
  screenRecord = pkgs.callPackage ./scripts/screen-record.nix { };
  screenshot = pkgs.callPackage ./scripts/screenshot.nix { };
  zoom = pkgs.callPackage ./scripts/zoom.nix { };
  keybinds-yad = pkgs.callPackage ./scripts/keybinds-yad.nix { inherit host; };

  app = "uwsm app --";
  backgroundApp = "uwsm app -s b --";
  serviceApp = "uwsm app -s s --";
  caelestia = "${app} caelestia";
  launcher = "${app} launcher";
  isCaelestia = bar == "caelestia-shell";
  gamesCmd = if isCaelestia then "${app} caelestia shell games open" else "${launcher} games";
  tmuxCmd = if isCaelestia then "${app} caelestia shell tmux open" else "${launcher} tmux";
  musicCmd =
    if isCaelestia then
      "${app} caelestia shell music open"
    else
      let
        rofimusic = pkgs.callPackage ./scripts/rofimusic.nix { };
      in
      "${app} ${getExe rofimusic}";

  barToggle = ''pkill -x "waybar|caelestia-shell|quickshell" || ${serviceApp} ${bar}'';
  clipmanagerCmd = "${app} ${getExe clipmanager}";
  gamemodeCmd = getExe gamemode;
  keybindsYadCmd = "${app} ${getExe keybinds-yad}";
  keyboardswitchCmd = getExe keyboardswitch;
  nightModeCmd = "${backgroundApp} ${getExe pkgs.hyprsunset} --temperature 3500";
  pearCmd = "${app} ${getExe pkgs.pear-desktop}";
  screenRecordCmd = "${app} ${getExe screenRecord}";
  screenshotCmd = "${app} ${getExe screenshot}";
  zoomCmd = getExe zoom;

  caelestiaBinds = {
    brightness = [
      ",XF86MonBrightnessDown,global,caelestia:brightnessDown"
      ",XF86MonBrightnessUp,global,caelestia:brightnessUp"
    ];
    session = [
      "$mainMod ALT, L, global, caelestia:lock"
      "$mainMod, backspace, global, caelestia:session"
    ];
    launcher = [
      "$mainMod, A, global, caelestia:launcher"
      "$mainMod, SPACE, global, caelestia:showall"
      "$mainMod SHIFT, I, global, caelestia:controlCenter"
      "$mainMod SHIFT, D, global, caelestia:dashboard"
      "$mainMod SHIFT, U, global, caelestia:utilities"
      "$mainMod, Z, exec, pkill -x fuzzel || ${caelestia} emoji -p"
      "$mainMod SHIFT, N, global, caelestia:sidebar"
      "$mainMod SHIFT, Q, global, caelestia:clearNotifs"
      "$mainMod, V, exec, pkill -x fuzzel || ${caelestia} clipboard"
    ];
    screenshot = [
      "$mainMod SHIFT, R, exec, ${caelestia} record -r -s"
      "$mainMod CTRL, R, exec, ${caelestia} record -s"
      "$mainMod, P, exec, ${caelestia} screenshot -r"
      "$mainMod CTRL, P, exec, ${caelestia} screenshot -r -f"
      "$mainMod, print, exec, ${caelestia} screenshot"
      "$mainMod CTRL, print, exec, ${screenshotCmd} m"
    ];
    media = [
      ",XF86AudioPlay,global,caelestia:mediaToggle"
      ",XF86AudioPause,global,caelestia:mediaToggle"
      ",XF86AudioStop,global,caelestia:mediaStop"
      ",xf86AudioNext,global,caelestia:mediaNext"
      ",xf86AudioPrev,global,caelestia:mediaPrev"
    ];
  };

  waybarBinds = {
    brightness = [
      ",XF86MonBrightnessDown,exec,brightnessctl set 1%-"
      ",XF86MonBrightnessUp,exec,brightnessctl set +1%"
    ];
    session = [
      "$mainMod ALT, L, exec, hyprlock"
      "$mainMod, backspace, exec, pkill -x wlogout || ${app} wlogout -b 4"
    ];
    launcher = [
      "$mainMod, A, exec, ${launcher} drun"
      "$mainMod, SPACE, exec, ${launcher} drun"
      "$mainMod SHIFT, W, exec, ${launcher} wallpaper"
      "$mainMod, Z, exec, ${launcher} emoji"
      "$mainMod SHIFT, N, exec, swaync-client -t -sw"
      "$mainMod SHIFT, Q, exec, swaync-client -t -sw"
      "$mainMod, V, exec, ${clipmanagerCmd}"
    ];
    screenshot = [
      "$mainMod SHIFT, R, exec, ${screenRecordCmd} a"
      "$mainMod CTRL, R, exec, ${screenRecordCmd} m"
      "$mainMod, P, exec, ${screenshotCmd} s"
      "$mainMod CTRL, P, exec, ${screenshotCmd} sf"
      "$mainMod, print, exec, ${screenshotCmd} p"
      "$mainMod CTRL, print, exec, ${screenshotCmd} m"
    ];
    media = [
      ",XF86AudioPlay,exec,playerctl play-pause"
      ",XF86AudioPause,exec,playerctl play-pause"
      ",XF86AudioStop,exec,playerctl stop"
      ",xf86AudioNext,exec,playerctl next"
      ",xf86AudioPrev,exec,playerctl previous"
    ];
  };

  selectedBarBinds = if isCaelestia then caelestiaBinds else waybarBinds;
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
  ]
  ++ selectedBarBinds.brightness
  ++ [
    # Volume controls
    ",XF86AudioLowerVolume,exec,pamixer -d 1"
    ",XF86AudioRaiseVolume,exec,pamixer -i 1"
  ];

  # Main keybindings
  bind = [
    # === Keybinds Help Menu ===
    "$mainMod, question, exec, ${keybindsYadCmd}"
    "$mainMod, slash, exec, ${keybindsYadCmd}"
    "$mainMod CTRL, K, exec, ${keybindsYadCmd}"

    # === Night Mode ===
    "$mainMod, F9, exec, ${nightModeCmd}"
    "$mainMod, F10, exec, pkill hyprsunset"

    # === Window/Session Actions ===
    "$mainMod, Q, killactive"
    "ALT, F4, forcekillactive"
    "$mainMod, delete, exit"
    "$mainMod, W, togglefloating"
    "$mainMod SHIFT, G, togglegroup"
    "ALT, return, fullscreen"
  ]
  ++ selectedBarBinds.session
  ++ [
    "CTRL, ESCAPE, exec, ${barToggle}"

    # === Applications ===
    # Note: $term, $editor, $fileManager, $browser are defined in default.nix settings
    "$mainMod, Return, exec, $term"
    "$mainMod, T, exec, $term"
    "$mainMod, E, exec, $fileManager"
    "$mainMod, C, exec, $editor"
    "$mainMod, F, exec, $browser"
    "$mainMod SHIFT, S, exec, uwsm app -- spotify"
    "$mainMod SHIFT, Y, exec, ${pearCmd}"
    "CTRL ALT, DELETE, exec, $term -e '${getExe pkgs.btop}'"
    "$mainMod CTRL, C, exec, hyprpicker --autocopy --format=hex"

    # === Launchers ===
  ]
  ++ selectedBarBinds.launcher
  ++ [
    "$mainMod SHIFT, T, exec, ${tmuxCmd}"
  ]
  ++ [ "$mainMod, G, exec, ${gamesCmd}" ]
  ++ [
    "$mainMod ALT, K, exec, ${keyboardswitchCmd}"
    "$mainMod ALT, G, exec, ${gamemodeCmd}"
    "$mainMod SHIFT, M, exec, ${musicCmd}"

    # === Screenshot/Screencapture ===
  ]
  ++ selectedBarBinds.screenshot
  ++ [
    # === Media Controls ===
    ",xf86Sleep, exec, systemctl suspend"
    ",XF86AudioMicMute,exec,pamixer --default-source -t"
    "$mainMod,M,exec,pamixer --default-source -t"
    ",XF86AudioMute,exec,pamixer -t"
  ]
  ++ selectedBarBinds.media
  ++ [
    # === Window Navigation ===
    "$mainMod, Tab, cyclenext"
    "$mainMod, Tab, bringactivetotop"
    "$mainMod, X, layoutmsg, togglesplit"

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
    "$mainMod SHIFT CTRL, left, movewindow, l"
    "$mainMod SHIFT CTRL, right, movewindow, r"
    "$mainMod SHIFT CTRL, up, movewindow, u"
    "$mainMod SHIFT CTRL, down, movewindow, d"

    # Move window in current workspace (HJKL)
    "$mainMod SHIFT CTRL, H, movewindow, l"
    "$mainMod SHIFT CTRL, L, movewindow, r"
    "$mainMod SHIFT CTRL, K, movewindow, u"
    "$mainMod SHIFT CTRL, J, movewindow, d"

    # === Zoom ===
    "$mainMod CTRL, mouse_down, exec, ${zoomCmd} in"
    "$mainMod CTRL, mouse_up, exec, ${zoomCmd} out"

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
          toString (x + 1 - (c * 10));
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
