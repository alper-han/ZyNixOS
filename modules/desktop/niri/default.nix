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
  editorPackage =
    if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor};
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

  services.displayManager.defaultSession = "niri";
  services.upower.enable = isLaptop;

  systemd.user.services.polkit-gnome-authentication-agent = {
    description = "Polkit authentication agent for Niri";
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

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    useNautilus = false;
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = with pkgs; [
          alacritty # Niri's upstream default config expects this terminal.
          app2unit
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
          waybar
          wf-recorder
          wl-clipboard
          wtype
          xdg-utils
          xwayland-satellite
        ];

        xdg.configFile."niri/config.kdl".text = ''
          prefer-no-csd

          environment {
              XDG_CURRENT_DESKTOP "niri"
              XDG_SESSION_DESKTOP "niri"
              XDG_SESSION_TYPE "wayland"
              GDK_BACKEND "wayland,x11,*"
              SDL_VIDEODRIVER "wayland,x11"
              CLUTTER_BACKEND "wayland"
              ELECTRON_OZONE_PLATFORM_HINT "auto"
              MOZ_ENABLE_WAYLAND "1"
              QT_QPA_PLATFORM "wayland;xcb"
              QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
              QT_AUTO_SCREEN_SCALE_FACTOR "1"
              QT_ENABLE_HIGHDPI_SCALING "1"
              XCURSOR_THEME "catppuccin-mocha-mauve-cursors"
              XCURSOR_SIZE "${toString config.home.pointerCursor.size}"
          }

          input {
              keyboard {
                  xkb {
                      layout "${kbdLayout}"
                      ${lib.optionalString (kbdVariant != "") ''variant "${kbdVariant}"''}
                  }
                  repeat-delay 275
                  repeat-rate 35
              }

              touchpad {
                  tap
              }

              mouse {
                  accel-profile "flat"
              }

              trackpoint {
                  accel-profile "flat"
              }
          }

          layout {
              gaps 3
              center-focused-column "never"
              default-column-width { proportion 0.5; }

              focus-ring {
                  width 1
                  active-color "#ca9ee6"
                  inactive-color "#6c7086"
              }

              border {
                  off
              }

              shadow {
                  off
              }
          }

          overview {
              zoom 0.5
              backdrop-color "#11111b"
          }

          hotkey-overlay {
              skip-at-startup
          }

          spawn-at-startup "${getExe pkgs.swaybg}" "-i" "${wallpaper}" "-m" "fill"
          spawn-at-startup "${getExe pkgs.waybar}"
          spawn-at-startup "${getExe pkgs.mako}"
          spawn-at-startup "${getExe' pkgs.wl-clipboard "wl-paste"}" "--type" "text" "--watch" "${getExe pkgs.cliphist}" "store"
          spawn-at-startup "${getExe' pkgs.wl-clipboard "wl-paste"}" "--type" "image" "--watch" "${getExe pkgs.cliphist}" "store"
          spawn-at-startup "${getExe' pkgs.coreutils "rm"}" "-f" "${config.xdg.cacheHome}/cliphist/db"
          spawn-at-startup "kdeconnect-indicator"

          binds {
              Mod+Slash { show-hotkey-overlay; }
              Mod+Question { show-hotkey-overlay; }

              Mod+Return { spawn "${getExe terminalPackage}"; }
              Mod+T { spawn "${getExe terminalPackage}"; }
              Mod+E { spawn-sh "${fileManagerCommand}"; }
              Mod+C { spawn "${getExe' editorPackage editor}"; }
              Mod+F { spawn "${browser}"; }
              Mod+D { spawn "${getExe pkgs.fuzzel}"; }
              Mod+Space { spawn "${getExe pkgs.fuzzel}"; }
              Mod+V { spawn-sh "pkill -x fuzzel || ${getExe pkgs.cliphist} list | ${getExe pkgs.fuzzel} --dmenu | ${getExe pkgs.cliphist} decode | ${getExe' pkgs.wl-clipboard "wl-copy"}"; }

              Mod+Q { close-window; }
              Alt+F4 { close-window; }
              Mod+W { toggle-window-floating; }
              Alt+Return { fullscreen-window; }
              Mod+Shift+E { quit; }
              Mod+Alt+L { spawn "${getExe pkgs.swaylock}" "--color" "11111b"; }

              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-window-down; }
              Mod+Up    { focus-window-up; }
              Mod+Right { focus-column-right; }
              Mod+H     { focus-column-left; }
              Mod+J     { focus-window-down; }
              Mod+K     { focus-window-up; }
              Mod+L     { focus-column-right; }

              Mod+Shift+Left  { move-column-left; }
              Mod+Shift+Down  { move-window-down; }
              Mod+Shift+Up    { move-window-up; }
              Mod+Shift+Right { move-column-right; }
              Mod+Shift+H     { move-column-left; }
              Mod+Shift+J     { move-window-down; }
              Mod+Shift+K     { move-window-up; }
              Mod+Shift+L     { move-column-right; }

              Mod+Ctrl+Left  { focus-workspace-up; }
              Mod+Ctrl+Right { focus-workspace-down; }
              Mod+Ctrl+H     { focus-workspace-up; }
              Mod+Ctrl+L     { focus-workspace-down; }
              Mod+Ctrl+Down  { focus-workspace-down; }
              Mod+Ctrl+Up    { focus-workspace-up; }

              Mod+Ctrl+Alt+Left  { move-column-to-workspace-up; }
              Mod+Ctrl+Alt+Right { move-column-to-workspace-down; }
              Mod+Ctrl+Alt+H     { move-column-to-workspace-up; }
              Mod+Ctrl+Alt+L     { move-column-to-workspace-down; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+0 { focus-workspace 10; }

              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }
              Mod+Shift+0 { move-column-to-workspace 10; }

              Mod+Tab { focus-window-or-workspace-down; }
              Mod+X { switch-preset-column-width; }
              Mod+R { switch-preset-window-height; }
              Mod+Ctrl+C { spawn "${getExe pkgs.hyprpicker}" "--autocopy" "--format=hex"; }

              Mod+P { screenshot; }
              Mod+Ctrl+P { screenshot-screen; }
              Mod+Shift+P { screenshot-window; }

              XF86AudioRaiseVolume allow-when-locked=true { spawn "${getExe pkgs.pamixer}" "-i" "1"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn "${getExe pkgs.pamixer}" "-d" "1"; }
              XF86AudioMute allow-when-locked=true { spawn "${getExe pkgs.pamixer}" "-t"; }
              XF86AudioMicMute allow-when-locked=true { spawn "${getExe pkgs.pamixer}" "--default-source" "-t"; }
              XF86AudioPlay allow-when-locked=true { spawn "${getExe pkgs.playerctl}" "play-pause"; }
              XF86AudioPause allow-when-locked=true { spawn "${getExe pkgs.playerctl}" "play-pause"; }
              XF86AudioStop allow-when-locked=true { spawn "${getExe pkgs.playerctl}" "stop"; }
              XF86AudioNext allow-when-locked=true { spawn "${getExe pkgs.playerctl}" "next"; }
              XF86AudioPrev allow-when-locked=true { spawn "${getExe pkgs.playerctl}" "previous"; }
              XF86MonBrightnessDown allow-when-locked=true { spawn "${getExe pkgs.brightnessctl}" "set" "1%-"; }
              XF86MonBrightnessUp allow-when-locked=true { spawn "${getExe pkgs.brightnessctl}" "set" "+1%"; }
          }

          window-rule {
              match app-id=r#"^(pavucontrol|blueman-manager|nm-connection-editor|org\.pulseaudio\.pavucontrol|swappy|hyprpicker)$"#
              open-floating true
          }

          window-rule {
              match title="Picture-in-Picture"
              open-floating true
              default-column-width { proportion 0.25; }
              default-window-height { proportion 0.25; }
              default-floating-position x=32 y=32 relative-to="top-right"
          }
        '';
      }
    )
  ];
}
