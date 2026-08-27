{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    editor
    fileManager
    kbdLayout
    kbdVariant
    isLaptop
    defaultWallpaper
    ;

  inherit (lib) getExe getExe';

  wallpapersDir = ../../themes/wallpapers;
  terminalPackage = pkgs.${terminal};
  editorPackage = if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor};
  wallpaper = "${wallpapersDir}/${defaultWallpaper}";
  fileManagerCommand =
    if fileManager == "thunar" then
      "thunar"
    else if fileManager == "yazi" || fileManager == "lf" then
      "${getExe terminalPackage} -e ${fileManager}"
    else
      fileManager;
in
{
  imports = [ ../../themes/Catppuccin ];

  services.displayManager.defaultSession = "wayfire";
  services.upower.enable = isLaptop;

  programs.wayfire = {
    enable = true;
    package = pkgs.wayfire;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
    xwayland.enable = true;
  };

  # Wayfire uses the wlroots portal for screencasts and screenshots and GTK for
  # file chooser, URI and print dialogs.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.wayfire = {
      default = [
        "wlr"
        "gtk"
      ];
      "org.freedesktop.impl.portal.OpenURI" = "gtk";
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
      "org.freedesktop.impl.portal.Print" = "gtk";
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent = {
    description = "Polkit authentication agent for Wayfire";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = with pkgs; [
          brightnessctl
          cliphist
          fuzzel
          grim
          hyprpicker
          libnotify
          mako
          pamixer
          pavucontrol
          playerctl
          slurp
          swaybg
          swayidle
          swaylock
          swappy
          wayfirePlugins.wf-shell
          wf-recorder
          wl-clipboard
          wtype
          xdg-utils
        ];

        xdg.configFile."wayfire.ini".text = ''
          [core]
          plugins = alpha animate autostart command decoration expo fast-switcher foreign-toplevel grid gtk-shell idle invert ipc ipc-rules move oswitch place resize session-lock shortcuts-inhibit switcher vswitch wayfire-shell window-rules wm-actions wobbly wrot zoom
          close_top_view = <super> KEY_Q | <alt> KEY_F4
          vwidth = 3
          vheight = 3
          preferred_decoration_mode = client

          [input]
          xkb_layout = ${kbdLayout}
          ${lib.optionalString (kbdVariant != "") "xkb_variant = ${kbdVariant}"}
          tap_to_click = true
          kb_repeat_delay = 275
          kb_repeat_rate = 35
          mouse_accel_profile = flat
          touchpad_accel_profile = flat

          [move]
          activate = <super> BTN_LEFT

          [resize]
          activate = <super> BTN_RIGHT

          [zoom]
          modifier = <super>

          [alpha]
          modifier = <super> <alt>

          [wrot]
          activate = <super> <ctrl> BTN_RIGHT

          [autostart]
          0_env = ${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE XCURSOR_SIZE XCURSOR_THEME
          autostart_wf_shell = false
          background = ${getExe pkgs.swaybg} -i ${wallpaper} -m fill
          panel = ${getExe' pkgs.wayfirePlugins.wf-shell "wf-panel"}
          notifications = ${getExe pkgs.mako}
          idle = ${getExe pkgs.swayidle} before-sleep ${getExe pkgs.swaylock} --color 11111b
          clipboard_text = ${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${getExe pkgs.cliphist} store
          clipboard_image = ${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${getExe pkgs.cliphist} store

          [command]
          binding_terminal = <super> KEY_ENTER | <super> KEY_T
          command_terminal = ${getExe terminalPackage}
          binding_file_manager = <super> KEY_E
          command_file_manager = ${fileManagerCommand}
          binding_editor = <super> KEY_C
          command_editor = ${getExe' editorPackage editor}
          binding_browser = <super> KEY_F
          command_browser = ${browser}
          binding_launcher = <super> KEY_D | <super> KEY_SPACE
          command_launcher = ${getExe pkgs.fuzzel}
          binding_clipboard = <super> KEY_V
          command_clipboard = sh -c 'pkill -x fuzzel || ${getExe pkgs.cliphist} list | ${getExe pkgs.fuzzel} --dmenu | ${getExe pkgs.cliphist} decode | ${getExe' pkgs.wl-clipboard "wl-copy"}'
          binding_lock = <super> <alt> KEY_L
          command_lock = ${getExe pkgs.swaylock} --color 11111b
          binding_quit = <super> <shift> KEY_E
          command_quit = ${getExe' pkgs.procps "pkill"} -TERM -x wayfire
          binding_color_picker = <super> <ctrl> KEY_C
          command_color_picker = ${getExe pkgs.hyprpicker} --autocopy --format=hex
          binding_screenshot = <super> KEY_P
          command_screenshot = sh -c '${getExe pkgs.grim} -g "$(${getExe pkgs.slurp})" - | ${getExe pkgs.swappy} -f -'
          binding_screenshot_full = <super> <ctrl> KEY_P
          command_screenshot_full = sh -c '${getExe pkgs.grim} - | ${getExe pkgs.swappy} -f -'
          repeatable_binding_volume_up = KEY_VOLUMEUP
          command_volume_up = ${getExe pkgs.pamixer} -i 1
          repeatable_binding_volume_down = KEY_VOLUMEDOWN
          command_volume_down = ${getExe pkgs.pamixer} -d 1
          binding_mute = KEY_MUTE
          command_mute = ${getExe pkgs.pamixer} -t
          binding_mic_mute = KEY_MICMUTE
          command_mic_mute = ${getExe pkgs.pamixer} --default-source -t
          binding_play_pause = KEY_PLAYPAUSE
          command_play_pause = ${getExe pkgs.playerctl} play-pause
          binding_next = KEY_NEXTSONG
          command_next = ${getExe pkgs.playerctl} next
          binding_previous = KEY_PREVIOUSSONG
          command_previous = ${getExe pkgs.playerctl} previous
          repeatable_binding_brightness_down = KEY_BRIGHTNESSDOWN
          command_brightness_down = ${getExe pkgs.brightnessctl} set 1%-
          repeatable_binding_brightness_up = KEY_BRIGHTNESSUP
          command_brightness_up = ${getExe pkgs.brightnessctl} set +1%

          [wm-actions]
          toggle_fullscreen = <super> KEY_M
          toggle_always_on_top = <super> KEY_X

          [grid]
          slot_tl = <super> KEY_KP7
          slot_t = <super> KEY_KP8
          slot_tr = <super> KEY_KP9
          slot_l = <super> KEY_LEFT | <super> KEY_KP4
          slot_c = <super> KEY_UP | <super> KEY_KP5
          slot_r = <super> KEY_RIGHT | <super> KEY_KP6
          slot_bl = <super> KEY_KP1
          slot_b = <super> KEY_KP2
          slot_br = <super> KEY_KP3
          restore = <super> KEY_DOWN | <super> KEY_KP0

          [switcher]
          next_view = <alt> KEY_TAB
          prev_view = <alt> <shift> KEY_TAB

          [fast-switcher]
          activate = <alt> KEY_ESC

          [vswitch]
          binding_left = <ctrl> <super> KEY_LEFT | <ctrl> <super> KEY_H
          binding_down = <ctrl> <super> KEY_DOWN | <ctrl> <super> KEY_J
          binding_up = <ctrl> <super> KEY_UP | <ctrl> <super> KEY_K
          binding_right = <ctrl> <super> KEY_RIGHT | <ctrl> <super> KEY_L
          with_win_left = <ctrl> <super> <shift> KEY_LEFT | <ctrl> <super> <shift> KEY_H
          with_win_down = <ctrl> <super> <shift> KEY_DOWN | <ctrl> <super> <shift> KEY_J
          with_win_up = <ctrl> <super> <shift> KEY_UP | <ctrl> <super> <shift> KEY_K
          with_win_right = <ctrl> <super> <shift> KEY_RIGHT | <ctrl> <super> <shift> KEY_L
          binding_1 = <super> KEY_1
          binding_2 = <super> KEY_2
          binding_3 = <super> KEY_3
          binding_4 = <super> KEY_4
          binding_5 = <super> KEY_5
          binding_6 = <super> KEY_6
          binding_7 = <super> KEY_7
          binding_8 = <super> KEY_8
          binding_9 = <super> KEY_9
          binding_10 = <super> KEY_0
          with_win_1 = <super> <shift> KEY_1
          with_win_2 = <super> <shift> KEY_2
          with_win_3 = <super> <shift> KEY_3
          with_win_4 = <super> <shift> KEY_4
          with_win_5 = <super> <shift> KEY_5
          with_win_6 = <super> <shift> KEY_6
          with_win_7 = <super> <shift> KEY_7
          with_win_8 = <super> <shift> KEY_8
          with_win_9 = <super> <shift> KEY_9
          with_win_10 = <super> <shift> KEY_0

          [expo]
          toggle = <super> KEY_TAB

          [oswitch]
          next_output = <super> KEY_O
          next_output_with_win = <super> <shift> KEY_O

          [wayfire-shell]
          toggle_menu = <super> KEY_ESC

          [decoration]
          active_color = 0.796 0.651 0.902 1.0
          inactive_color = 0.424 0.439 0.525 1.0
          border_size = 1

          [window-rules]
          floating_pavucontrol = on created if app_id is "pavucontrol" then set geometry 30 30 40% 40%
          floating_swappy = on created if app_id is "swappy" then set geometry 30 30 40% 40%
        '';

        xdg.configFile."environment.d/wayfire.conf".text = ''
          XDG_CURRENT_DESKTOP=Wayfire
          XDG_SESSION_DESKTOP=Wayfire
          XDG_SESSION_TYPE=wayland
          GDK_BACKEND=wayland,x11,*
          SDL_VIDEODRIVER=wayland,x11
          CLUTTER_BACKEND=wayland
          ELECTRON_OZONE_PLATFORM_HINT=auto
          MOZ_ENABLE_WAYLAND=1
          QT_QPA_PLATFORM=wayland;xcb
          QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          QT_AUTO_SCREEN_SCALE_FACTOR=1
          QT_ENABLE_HIGHDPI_SCALING=1
          XCURSOR_THEME=catppuccin-mocha-mauve-cursors
          XCURSOR_SIZE=${toString config.home.pointerCursor.size}
        '';

        xdg.configFile."systemd/user/xdg-desktop-portal-gtk.service.d/wayfire-theme.conf".text = ''
          [Service]
          Environment=GTK_THEME=Adwaita:dark
          Environment=XDG_CURRENT_DESKTOP=Wayfire
        '';
      }
    )
  ];
}
