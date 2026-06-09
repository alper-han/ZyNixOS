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

  # TODO: Drop after Hyprland 0.55.2 if portal access works without this wrapper override.
  security.wrappers.Hyprland.capabilities = lib.mkIf (lib.versionAtLeast pkgs.hyprland.version "0.55.2" && lib.versionOlder pkgs.hyprland.version "0.55.3") (
    lib.mkForce ""
  );

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
                "$browser" = "uwsm app -- ${browser} --blank-window";

                # Input settings
                input = {
                  kb_layout = "${kbdLayout}";
                  numlock_by_default = true;
                  repeat_delay = 250;
                  repeat_rate = 35;

                  follow_mouse = 1;
                  off_window_axis_events = 2;

                  touchpad = {
                    natural_scroll = false;
                    disable_while_typing = true;
                    clickfinger_behavior = true;
                    scroll_factor = 0.7;
                  };

                  tablet.output = "current";

                  sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                  accel_profile = "flat";
                }
                // lib.optionalAttrs (kbdVariant != "") {
                  kb_variant = "${kbdVariant}";
                };

                # Render settings
                render = {
                  cm_auto_hdr = 0;
                  # direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type 'game' , It causes problems in some games)
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
                  on_focus_under_fullscreen = false;
                  anr_missed_pings = 3;
                  disable_hyprland_logo = true;
                  disable_splash_rendering = true;
                  mouse_move_focuses_monitor = true;
                  mouse_move_enables_dpms = true;
                  key_press_enables_dpms = true;
                  animate_manual_resizes = false;
                  animate_mouse_windowdragging = false;
                  force_default_wallpaper = 0;
                  swallow_regex = "(foot|kitty|allacritty|Alacritty)";
                  enable_swallow = false;
                  disable_autoreload = true; # If true, the config will not reload automatically on save, and instead needs to be reloaded with hyprctl reload. Might save on battery.
                  disable_hyprland_guiutils_check = true;
                  vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only, 3 = fullscreen games/media)
                  allow_session_lock_restore = true;
                  session_lock_xray = true;
                  initial_workspace_tracking = false;
                  focus_on_activate = true;
                  background_color = "rgb(201f23)";
                };

                # Cursor settings
                cursor = {
                  no_hardware_cursors = false;
                  enable_hyprcursor = true;
                  sync_gsettings_theme = false;
                  zoom_factor = 1.0;
                  zoom_rigid = false;
                  zoom_disable_aa = true;
                  hotspot_padding = 1;
                };

                # XWayland settings
                xwayland.force_zero_scaling = true;

                # Gestures
                gesture = [
                  "3, swipe, move"
                  "3, pinch, fullscreen"
                  "4, horizontal, workspace"
                ];

                gestures = {
                  workspace_swipe_distance = 700;
                  workspace_swipe_cancel_ratio = 0.2;
                  workspace_swipe_min_speed_to_force = 5;
                  workspace_swipe_direction_lock = true;
                  workspace_swipe_direction_lock_threshold = 10;
                  workspace_swipe_create_new = true;
                };

                # Dwindle layout settings
                dwindle = {
                  # pseudotile = true;
                  preserve_split = true;
                  smart_split = false;
                  smart_resizing = false;
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
