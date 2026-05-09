{ pkgs, host, ... }:
let
  inherit (pkgs.lib) getExe getExe';
  inherit (import ../../../../hosts/${host}/variables.nix)
    browser
    editor
    terminal
    fileManager
    bar
    ;
  fileManagerScript = pkgs.callPackage ./file-manager.nix { inherit terminal; };
  clipmanager = pkgs.callPackage ./clipmanager.nix { };
  screen-record = pkgs.callPackage ./screen-record.nix { };
  screenshot = pkgs.callPackage ./screenshot.nix { };
  terminalCmd = "uwsm app -- ${terminal}";
  editorCmd = "uwsm app -- ${
    getExe' (
      if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor}
    ) editor
  }";
  fileManagerCmd = "uwsm app -- ${getExe fileManagerScript} ${fileManager}";
  browserCmd = "uwsm app -- ${browser}";
  barCmd = ''pkill -x \"waybar|caelestia-shell|quickshell\" || uwsm app -s s -- ${bar}'';
  isCaelestia = bar == "caelestia-shell";
  gamesCmd = if isCaelestia then "uwsm app -- caelestia shell games open" else "uwsm app -- launcher games";
  tmuxCmd = if isCaelestia then "uwsm app -- caelestia shell tmux open" else "uwsm app -- launcher tmux";
  musicCmd =
    if isCaelestia then
      "uwsm app -- caelestia shell music open"
    else
      let
        rofimusic = pkgs.callPackage ./rofimusic.nix { };
      in
      "uwsm app -- ${getExe rofimusic}";

  brightnessRows =
    if isCaelestia then
      ''
        "XF86MonBrightnessDown" "Decrease brightness" "global caelestia:brightnessDown" \
        "XF86MonBrightnessUp" "Increase brightness" "global caelestia:brightnessUp" \
      ''
    else
      ''
        "XF86MonBrightnessDown" "Decrease brightness" "brightnessctl set 1%-" \
        "XF86MonBrightnessUp" "Increase brightness" "brightnessctl set +1%" \
      '';

  launcherRows =
    if isCaelestia then
      ''
        "SUPER A" "Toggle Caelestia launcher" "global caelestia:launcher" \
        "SUPER SPACE" "Toggle Caelestia panels" "global caelestia:showall" \
        "SUPER SHIFT I" "Open Caelestia control center" "global caelestia:controlCenter" \
        "SUPER SHIFT D" "Toggle Caelestia dashboard" "global caelestia:dashboard" \
        "SUPER SHIFT U" "Toggle Caelestia utilities" "global caelestia:utilities" \
      ''
    else
      ''
        "SUPER A" "Launch application menu" "uwsm app -- launcher drun" \
        "SUPER SPACE" "Launch application menu" "uwsm app -- launcher drun" \
        "SUPER SHIFT W" "Wallpaper picker" "uwsm app -- launcher wallpaper" \
      '';

  mediaRows =
    if isCaelestia then
      ''
        "XF86AudioPlay" "Play/Pause media" "global caelestia:mediaToggle" \
        "XF86AudioPause" "Play/Pause media" "global caelestia:mediaToggle" \
        "XF86AudioStop" "Stop media" "global caelestia:mediaStop" \
        "XF86AudioNext" "Next media track" "global caelestia:mediaNext" \
        "XF86AudioPrev" "Previous media track" "global caelestia:mediaPrev" \
      ''
    else
      ''
        "XF86AudioPlay" "Play/Pause media" "playerctl play-pause" \
        "XF86AudioPause" "Play/Pause media" "playerctl play-pause" \
        "XF86AudioStop" "Stop media" "playerctl stop" \
        "XF86AudioNext" "Next media track" "playerctl next" \
        "XF86AudioPrev" "Previous media track" "playerctl previous" \
      '';

  sessionRows =
    if isCaelestia then
      ''
        "SUPER ALT L" "Lock screen" "global caelestia:lock" \
        "SUPER Backspace" "Caelestia session menu" "global caelestia:session" \
      ''
    else
      ''
        "SUPER ALT L" "Lock screen" "hyprlock" \
        "SUPER Backspace" "Power/session menu" "pkill -x wlogout || uwsm app -- wlogout -b 4" \
      '';

  notificationRows =
    if isCaelestia then
      ''
        "SUPER SHIFT N" "Open Caelestia sidebar/notifications" "global caelestia:sidebar" \
        "SUPER SHIFT Q" "Clear Caelestia notifications" "global caelestia:clearNotifs" \
      ''
    else
      ''
        "SUPER SHIFT N" "Toggle notification center" "swaync-client -t -sw" \
        "SUPER SHIFT Q" "Toggle notification center" "swaync-client -t -sw" \
      '';

  utilityRows =
    if isCaelestia then
      ''
        "SUPER Z" "Launch Caelestia emoji picker" "pkill -x fuzzel || uwsm app -- caelestia emoji -p" \
        "SUPER V" "Caelestia clipboard manager" "pkill -x fuzzel || uwsm app -- caelestia clipboard" \
      ''
    else
      ''
        "SUPER Z" "Launch emoji picker" "uwsm app -- launcher emoji" \
        "SUPER V" "Clipboard manager" "uwsm app -- ${getExe clipmanager}" \
      '';

  rofiRows = ''
    "SUPER SHIFT T" "Launch tmux sessions" "${tmuxCmd}" \
    "SUPER SHIFT M" "Launch music menu" "${musicCmd}" \
  '';

  gamesRow =
    ''
      "SUPER G" "Game launcher" "${gamesCmd}" \
    '';

  screenshotRows =
    if isCaelestia then
      ''
        "SUPER SHIFT R" "Caelestia screen record (select area + audio)" "uwsm app -- caelestia record -r -s" \
        "SUPER CTRL R" "Caelestia screen record (focused monitor + audio)" "uwsm app -- caelestia record -s" \
        "SUPER P" "Caelestia screenshot selected area" "uwsm app -- caelestia screenshot -r" \
        "SUPER CTRL P" "Caelestia frozen screenshot selected area" "uwsm app -- caelestia screenshot -r -f" \
        "SUPER Print" "Caelestia screenshot all screens" "uwsm app -- caelestia screenshot" \
        "SUPER CTRL Print" "Screenshot focused monitor, save, and copy" "uwsm app -- ${getExe screenshot} m" \
      ''
    else
      ''
        "SUPER SHIFT R" "Screen record selected area" "uwsm app -- ${getExe screen-record} a" \
        "SUPER CTRL R" "Screen record selected monitor" "uwsm app -- ${getExe screen-record} m" \
        "SUPER P" "Screenshot selected area, edit, save, and copy" "uwsm app -- ${getExe screenshot} s" \
        "SUPER CTRL P" "Frozen screenshot selected area, edit, save, and copy" "uwsm app -- ${getExe screenshot} sf" \
        "SUPER Print" "Screenshot all screens, save, and copy" "uwsm app -- ${getExe screenshot} p" \
        "SUPER CTRL Print" "Screenshot focused monitor, save, and copy" "uwsm app -- ${getExe screenshot} m" \
      '';
in
pkgs.writeShellScriptBin "keybinds-yad" ''
  if ${pkgs.procps}/bin/pidof rofi >/dev/null; then
    ${pkgs.procps}/bin/pkill rofi
  fi

  if ${pkgs.procps}/bin/pidof yad >/dev/null; then
    ${pkgs.procps}/bin/pkill yad
  fi

  ${pkgs.yad}/bin/yad \
    --center \
    --title="Hyprland Keybinds" \
    --no-buttons \
    --list \
    --width=745 \
    --height=920 \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
    "SUPER ?" "Show this keybinds help" "uwsm app -- keybinds-yad" \
    "SUPER /" "Show this keybinds help" "uwsm app -- keybinds-yad" \
    "SUPER CTRL K" "Show this keybinds help" "uwsm app -- keybinds-yad" \
    "SUPER Return" "Launch terminal" "${terminalCmd}" \
    "SUPER T" "Launch terminal" "${terminalCmd}" \
    "SUPER E" "Launch file manager" "${fileManagerCmd}" \
    "SUPER C" "Launch editor" "${editorCmd}" \
    "SUPER F" "Launch browser" "${browserCmd}" \
    "SUPER SHIFT S" "Launch Spotify" "uwsm app -- spotify" \
    "SUPER SHIFT Y" "Launch Pear Desktop" "uwsm app -- ${getExe pkgs.pear-desktop}" \
    "CTRL ALT Delete" "Open system monitor" "${terminalCmd} -e btop" \
    ${launcherRows}
    ${gamesRow}
    ${rofiRows}
    "SUPER F9" "Enable night mode" "uwsm app -s b -- hyprsunset --temperature 3500" \
    "SUPER F10" "Disable night mode" "pkill hyprsunset" \
    "SUPER CTRL C" "Colour picker" "hyprpicker --autocopy --format=hex" \
    "SUPER, Left Click" "Move window with mouse" "movewindow" \
    "SUPER, Right Click" "Resize window with mouse" "resizewindow" \
    "SUPER SHIFT →" "Resize window right" "resizeactive 30 0" \
    "SUPER SHIFT ←" "Resize window left" "resizeactive -30 0" \
    "SUPER SHIFT ↑" "Resize window up" "resizeactive 0 -30" \
    "SUPER SHIFT ↓" "Resize window down" "resizeactive 0 30" \
    "SUPER SHIFT L" "Resize window right (HJKL)" "resizeactive 30 0" \
    "SUPER SHIFT H" "Resize window left (HJKL)" "resizeactive -30 0" \
    "SUPER SHIFT K" "Resize window up (HJKL)" "resizeactive 0 -30" \
    "SUPER SHIFT J" "Resize window down (HJKL)" "resizeactive 0 30" \
    ${brightnessRows}
    "XF86AudioLowerVolume" "Lower volume" "pamixer -d 1" \
    "XF86AudioRaiseVolume" "Increase volume" "pamixer -i 1" \
    "XF86AudioMicMute" "Mute microphone" "pamixer --default-source -t" \
    "SUPER M" "Mute microphone" "pamixer --default-source -t" \
    "XF86AudioMute" "Mute audio" "pamixer -t" \
    ${mediaRows}
    "XF86Sleep" "Suspend system" "systemctl suspend" \
    "SUPER Delete" "Exit Hyprland session" "exit" \
    "SUPER W" "Toggle floating window" "togglefloating" \
    "SUPER SHIFT G" "Toggle window group" "togglegroup" \
    "ALT Return" "Toggle fullscreen" "fullscreen" \
    ${sessionRows}
    "CTRL Escape" "Toggle bar" "${barCmd}" \
    ${notificationRows}
    "SUPER Q" "Close active window" "killactive" \
    "ALT F4" "Force kill active window" "forcekillactive" \
    ${utilityRows}
    "SUPER ALT K" "Change keyboard layout" "keyboardswitch" \
    "SUPER U" "Rebuild system" "${terminalCmd} -e rebuild" \
    "SUPER ALT G" "Enable game mode" "gamemode" \
    ${screenshotRows}
    "SUPER SHIFT CTRL ←" "Move window left" "movewindow l" \
    "SUPER SHIFT CTRL →" "Move window right" "movewindow r" \
    "SUPER SHIFT CTRL ↑" "Move window up" "movewindow u" \
    "SUPER SHIFT CTRL ↓" "Move window down" "movewindow d" \
    "SUPER SHIFT CTRL H" "Move window left (HJKL)" "movewindow l" \
    "SUPER SHIFT CTRL L" "Move window right (HJKL)" "movewindow r" \
    "SUPER SHIFT CTRL K" "Move window up (HJKL)" "movewindow u" \
    "SUPER SHIFT CTRL J" "Move window down (HJKL)" "movewindow d" \
    "SUPER CTRL ALT →" "Move window to next workspace" "movetoworkspace r+1" \
    "SUPER CTRL ALT ←" "Move window to previous workspace" "movetoworkspace r-1" \
    "SUPER CTRL S" "Move to scratchpad" "movetoworkspacesilent special" \
    "SUPER ALT S" "Move to scratchpad silently" "movetoworkspacesilent special" \
    "SUPER S" "Toggle scratchpad workspace" "togglespecialworkspace" \
    "SUPER Tab" "Cycle next window" "cyclenext" \
    "SUPER Tab" "Bring active window to top" "bringactivetotop" \
    "SUPER X" "Toggle dwindle split direction" "layoutmsg togglesplit" \
    "SUPER CTRL →" "Switch to next workspace" "workspace r+1" \
    "SUPER CTRL ←" "Switch to previous workspace" "workspace r-1" \
    "SUPER CTRL ↓" "Go to first empty workspace" "workspace empty" \
    "SUPER ←" "Move focus left" "movefocus l" \
    "SUPER →" "Move focus right" "movefocus r" \
    "SUPER ↑" "Move focus up" "movefocus u" \
    "SUPER ↓" "Move focus down" "movefocus d" \
    "SUPER H" "Move focus left (HJKL)" "movefocus l" \
    "SUPER L" "Move focus right (HJKL)" "movefocus r" \
    "SUPER K" "Move focus up (HJKL)" "movefocus u" \
    "SUPER J" "Move focus down (HJKL)" "movefocus d" \
    "ALT Tab" "Move focus down" "movefocus d" \
    "SUPER Mouse Wheel Down" "Switch to next workspace" "workspace e+1" \
    "SUPER Mouse Wheel Up" "Switch to previous workspace" "workspace e-1" \
    "SUPER Mouse Back" "Switch to workspace 5" "workspace 5" \
    "SUPER Mouse Forward" "Switch to workspace 6" "workspace 6" \
    "SUPER SHIFT Mouse Back" "Move window to workspace 5" "movetoworkspace 5" \
    "SUPER SHIFT Mouse Forward" "Move window to workspace 6" "movetoworkspace 6" \
    "SUPER CTRL Mouse Back" "Move window silently to workspace 5" "movetoworkspacesilent 5" \
    "SUPER CTRL Mouse Forward" "Move window silently to workspace 6" "movetoworkspacesilent 6" \
    "SUPER CTRL Mouse Wheel Down" "Zoom in" "zoom in" \
    "SUPER CTRL Mouse Wheel Up" "Zoom out" "zoom out" \
    "SUPER 1-0" "Switch to workspace 1-10" "workspace 1-10" \
    "SUPER ALT 1-0" "Switch to workspace 11-20" "workspace 11-20" \
    "SUPER SHIFT 1-0" "Move to workspace 1-10" "movetoworkspace 1-10" \
    "SUPER SHIFT ALT 1-0" "Move to workspace 11-20" "movetoworkspace 11-20" \
    "SUPER CTRL 1-0" "Move silently to workspace 1-10" "movetoworkspacesilent 1-10" \
    "SUPER CTRL ALT 1-0" "Move silently to workspace 11-20" "movetoworkspacesilent 11-20" \
    "F9 in OBS" "Pass F9 through to OBS" "pass class:^(com.obsproject.Studio)$" \
    "F10 in OBS" "Pass F10 through to OBS" "pass class:^(com.obsproject.Studio)$"
''
