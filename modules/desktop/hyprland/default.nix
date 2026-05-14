{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    username
    browser
    terminal
    editor
    fileManager
    bar
    kbdLayout
    kbdVariant
    isLaptop
    defaultWallpaper
    ;

  wallpapersDir = ../../themes/wallpapers;
  defaultWallpaperPath = "${wallpapersDir}/${defaultWallpaper}";
  caelestiaOwnsTheme = bar == "caelestia-shell";

  # Import sub-modules
  fileManagerScript = pkgs.callPackage ./scripts/file-manager.nix { inherit terminal; };
  bindSettings = import ./bind.nix { inherit lib pkgs host; };
  rulesSettings = import ./rules.nix { };
  uiSettings = import ./ui.nix { inherit bar; };
  monitorSettings = import ./monitor.nix { };
in
{
  imports = [
    ../../themes/Catppuccin # Catppuccin GTK and QT themes
    ./programs/${bar}
    ./programs/rofi
    # ./programs/dunst
  ]
  ++ lib.optional (bar != "caelestia-shell") ./programs/wlogout
  ++ lib.optional (bar != "caelestia-shell") ./programs/hyprlock
  ++ lib.optional (bar != "caelestia-shell") ./programs/hypridle
  ++ lib.optional (bar != "caelestia-shell") ./programs/swaync;

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
  services.upower.enable = isLaptop;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  home-manager.sharedModules =
    let
      inherit (lib) getExe getExe';
    in
    [
      (
        { config, ... }:
        let
          wallpaper = pkgs.callPackage ./scripts/wallpaper.nix { inherit defaultWallpaper; };
          # Import startup settings (needs config for cursor size)
          startupSettings = import ./startup.nix {
            inherit
              lib
              pkgs
              isLaptop
              bar
              ;
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

          home.packages =
            (with pkgs; [
              app2unit
              brightnessctl
              cliphist
              fuzzel
              gpu-screen-recorder
              grim
              grimblast
              hyprpicker
              libnotify
              pamixer
              pavucontrol
              playerctl
              slurp
              swappy
              wf-recorder
              wl-clipboard
              wtype
              yad
              # socat # for and autowaybar.sh
              bc # zoom
            ])
            ++ lib.optional (bar != "caelestia-shell") pkgs.awww;

          xdg.configFile."hypr/icons" = {
            source = ./icons;
            recursive = true;
          };

          # Set wallpaper. Caelestia owns the background/wallpaper layer when it is the active shell.
          services.awww.enable = bar != "caelestia-shell";
          systemd.user.services.awww = lib.mkIf (bar != "caelestia-shell") {
            Service.ExecStartPost = [ "${getExe wallpaper}" ];
          };

          systemd.user.tmpfiles.rules = lib.optionals (bar == "caelestia-shell") [
            "d %S/caelestia/wallpaper 0755 ${username} users - -"
            "f %S/caelestia/wallpaper/path.txt 0644 ${username} users - ${defaultWallpaperPath}"
          ];

          xdg.configFile."hypr/xdph.conf".text = ''
            screencopy {
              max_fps = 144
              allow_token_by_default = true
            }
          '';

          xdg.configFile."uwsm/env".text = ''
            export XDG_CURRENT_DESKTOP=Hyprland
            export XDG_SESSION_DESKTOP=Hyprland
            export XDG_SESSION_TYPE=wayland
            export GDK_BACKEND=wayland,x11,*
            export SDL_VIDEODRIVER=wayland,x11
            export CLUTTER_BACKEND=wayland
            export ELECTRON_OZONE_PLATFORM_HINT=auto
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM="wayland;xcb"
            export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
            ${lib.optionalString (!caelestiaOwnsTheme) ''
              export QT_QPA_PLATFORMTHEME=hyprqt6engine
            ''}
            export QT_AUTO_SCREEN_SCALE_FACTOR=1
            export QT_ENABLE_HIGHDPI_SCALING=1
            export XCURSOR_THEME=catppuccin-mocha-mauve-cursors
            export XCURSOR_SIZE=${toString config.home.pointerCursor.size}
          '';

          xdg.configFile."uwsm/env-hyprland".text = ''
            export HYPRCURSOR_THEME=catppuccin-mocha-mauve-cursors
            export HYPRCURSOR_SIZE=${toString config.home.pointerCursor.size}
          '';

          xdg.configFile."systemd/user/xdg-desktop-portal-gtk.service.d/caelestia-theme.conf" =
            lib.mkIf caelestiaOwnsTheme
              {
                text = ''
                  [Service]
                  Environment=GTK_THEME=adw-gtk3-dark
                  Environment=ADW_COLOR_SCHEME=prefer-dark
                  Environment=XDG_CONFIG_HOME=${config.xdg.configHome}
                '';
              };

          #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
          wayland.windowManager.hyprland = {
            enable = true;
            package = pkgs.hyprland;
            configType = "hyprlang";
            plugins = [ ];
            systemd.enable = false; # Disabled to avoid conflicts with UWSM
            settings =
              # Application variables (used in keybindings)
              {
                "$term" = "uwsm app -- ${getExe pkgs.${terminal}}";
                "$editor" = "uwsm app -- ${
                  getExe' (
                    if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor}
                  ) editor
                }";
                "$fileManager" = "uwsm app -- ${getExe fileManagerScript} ${fileManager}";
                "$browser" = "uwsm app -- ${browser}";

                # Input settings
                input = {
                  kb_layout = "${kbdLayout}";
                  repeat_delay = 275; # or 212
                  repeat_rate = 35;
                  numlock_by_default = true;

                  follow_mouse = 1;

                  touchpad.natural_scroll = false;

                  tablet.output = "current";

                  sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                  accel_profile = "flat";
                }
                // lib.optionalAttrs (kbdVariant != "") {
                  kb_variant = "${kbdVariant}";
                };

                # Render settings
                render = {
                  direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type 'game' , It causes problems in some games)
                  cm_auto_hdr = 0;
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
                  enable_swallow = false;
                  disable_autoreload = true; # If true, the config will not reload automatically on save, and instead needs to be reloaded with hyprctl reload. Might save on battery.
                  disable_hyprland_guiutils_check = true;
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
                  # pseudotile = true;
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
                  disable_logs = false;
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
