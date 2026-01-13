{
  host,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    editor
    kbdLayout
    kbdVariant
    defaultWallpaper
    ;

  # Import sub-modules
  bindSettings = import ./bind.nix { inherit lib pkgs; };
  rulesSettings = import ./rules.nix { };
  uiSettings = import ./ui.nix { };
  monitorSettings = import ./monitor.nix { };
in
{
  imports = [
    ../../themes/Catppuccin # Catppuccin GTK and QT themes
    ./programs/waybar
    ./programs/wlogout
    ./programs/rofi
    ./programs/hypridle
    ./programs/hyprlock
    ./programs/swaync
    # ./programs/dunst
  ];

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent - Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # Use Hyprland from flake input to leverage Cachix cache
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  home-manager.sharedModules =
    let
      inherit (lib) getExe getExe';
    in
    [
      (
        { config, ... }:
        let
          # Import startup settings (needs config for cursor size)
          startupSettings = import ./startup.nix {
            inherit lib pkgs config defaultWallpaper;
          };
        in
        {
          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
            ];
            xdgOpenUsePortal = true;
            configPackages = [ config.wayland.windowManager.hyprland.package ];
            config.hyprland = {
              default = [
                "hyprland"
                "gtk"
              ];
              "org.freedesktop.impl.portal.OpenURI" = "gtk";
              "org.freedesktop.impl.portal.FileChooser" = "gtk";
              "org.freedesktop.impl.portal.Print" = "gtk";
            };
          };

          home.packages = with pkgs; [
            swww
            hyprpicker
            cliphist
            wf-recorder
            grim
            grimblast
            slurp
            swappy
            libnotify
            brightnessctl
            networkmanagerapplet
            pamixer
            pavucontrol
            playerctl
            wtype
            wl-clipboard
            xdotool
            yad
            # socat # for and autowaybar.sh
            jq # for and autowaybar.sh zoom
            bc # zoom
            wl-clip-persist
            rose-pine-hyprcursor
          ];

          xdg.configFile."hypr/icons" = {
            source = ./icons;
            recursive = true;
          };

          # Set wallpaper
          services.swww.enable = true;

          xdg.configFile."hypr/xdph.conf".text = ''
            screencopy {
              max_fps = 144
              allow_token_by_default = true
            }
          '';

          xdg.configFile."uwsm/env".text = ''
            export GDK_BACKEND=wayland,x11,*
            export SDL_VIDEODRIVER=wayland
            export CLUTTER_BACKEND=wayland
            export ELECTRON_OZONE_PLATFORM_HINT=wayland
            export MOZ_ENABLE_WAYLAND=1
            export OZONE_PLATFORM=wayland
            export EGL_PLATFORM=wayland
            export QT_QPA_PLATFORM=wayland;xcb
            export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
            export QT_QPA_PLATFORMTHEME=hyprqt6engine
            export QT_AUTO_SCREEN_SCALE_FACTOR=1
            export QT_ENABLE_HIGHDPI_SCALING=1
            export HYPRCURSOR_THEME=rose-pine-hyprcursor
            export HYPRCURSOR_SIZE=${toString config.home.pointerCursor.size}
            export XCURSOR_THEME=rose-pine-hyprcursor
            export XCURSOR_SIZE=${toString config.home.pointerCursor.size}
          '';

          #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
          wayland.windowManager.hyprland = {
            enable = true;
            plugins = [ ];
            systemd.enable = false; # Disabled to avoid conflicts with UWSM
            settings =
              # Application variables (used in keybindings)
              {
                "$term" = "${getExe pkgs.${terminal}}";
                "$editor" = "${getExe' (
                  if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor}
                ) editor}";
                "$fileManager" = "thunar";
                "$browser" = browser;

                # Input settings
                input = {
                  kb_layout = "${kbdLayout}";
                  kb_variant = "${kbdVariant}";
                  repeat_delay = 275; # or 212
                  repeat_rate = 35;
                  numlock_by_default = true;

                  follow_mouse = 1;

                  touchpad.natural_scroll = false;

                  tablet.output = "current";

                  sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                  accel_profile = "flat";
                };

                # Render settings
                render = {
                  direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type 'game' , It causes problems in some games)
                  cm_fs_passthrough = 2;
                  cm_auto_hdr = 1;
                  # new_render_scheduling = true;
                };

                # Ecosystem settings
                ecosystem = {
                  no_update_news = true;
                  no_donation_nag = true;
                };

                # Miscellaneous settings
                misc = {
                  middle_click_paste = false;
                  on_focus_under_fullscreen = false; # test
                  anr_missed_pings = 3;
                  disable_hyprland_logo = true;
                  mouse_move_focuses_monitor = true;
                  animate_manual_resizes = true;
                  animate_mouse_windowdragging = true;
                  force_default_wallpaper = 0;
                  swallow_regex = "^(Alacritty|kitty)$";
                  enable_swallow = true;
                  disable_autoreload = true; # If true, the config will not reload automatically on save, and instead needs to be reloaded with hyprctl reload. Might save on battery.
                  disable_hyprland_guiutils_check = true;
                  vfr = true; # always keep on
                  vrr = 2; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only, 3 = fullscreen games/media)
                };

                # Cursor settings
                cursor = {
                  no_hardware_cursors = false;
                  enable_hyprcursor = true;
                  sync_gsettings_theme = false;
                  zoom_factor = 1.0;
                  zoom_rigid = false;
                };

                # XWayland settings
                xwayland.force_zero_scaling = false;

                # Gestures
                gesture = [
                  "3, horizontal, workspace"
                ];

                # Dwindle layout settings
                dwindle = {
                  pseudotile = true;
                  preserve_split = true;
                };

                # Master layout settings
                master = {
                  new_status = "master";
                  new_on_top = true;
                  mfact = 0.5;
                };

                # Debug settings
                debug = {
                  disable_logs = true;
                  enable_stdout_logs = false;
                };
              }
              # Merge all sub-module settings
              // bindSettings
              // rulesSettings
              // uiSettings
              // monitorSettings
              // startupSettings;
          };
        }
      )
    ];
}
