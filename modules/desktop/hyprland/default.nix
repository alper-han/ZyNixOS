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
    videoDriver
    ;

  wallpapersDir = ../../themes/wallpapers;
  defaultWallpaperPath = "${wallpapersDir}/${defaultWallpaper}";
  caelestiaOwnsTheme = bar == "caelestia-shell";

  fileManagerScript = pkgs.callPackage ./scripts/file-manager.nix { inherit terminal; };
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

  programs.gpu-screen-recorder.enable = bar == "caelestia-shell";

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
        in
        {
          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
            ];
            xdgOpenUsePortal = true;
            configPackages = [ pkgs.hyprland ];
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
              # app2unit
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

          xdg.configFile = {
            "hypr/hyprland.lua".source = ./lua/hyprland.lua;
            "hypr/settings.lua".source = ./lua/settings.lua;
            "hypr/animations.lua".source = ./lua/animations.lua;
            "hypr/binds.lua".source = ./lua/binds.lua;
            "hypr/rules.lua".source = ./lua/rules.lua;
            "hypr/monitors.lua".source = ./lua/monitors.lua;
            "hypr/variables.lua".text = let
              luaString = value: builtins.toJSON value;
              editorExe = getExe' (
                if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor}
              ) editor;
              app = "uwsm app --";
              backgroundApp = "uwsm app -s b --";
              serviceApp = "uwsm app -s s --";
              caelestia = "${app} caelestia";
              launcher = "${app} launcher";
              barCommand = if bar == "caelestia-shell" then "${serviceApp} caelestia shell -d" else "${serviceApp} ${bar}";
              barToggle = ''pkill -x "waybar|caelestia-shell|quickshell" || ${barCommand}'';
              clearClipboardCommand = "${app} ${getExe' pkgs.coreutils "rm"} -f \${XDG_CACHE_HOME:-\$HOME/.cache}/cliphist/db";
            in ''
              mainMod = "SUPER"
              isCaelestia = ${lib.boolToString (bar == "caelestia-shell")}
              barCommand = ${luaString barCommand}
              bar_toggle = ${luaString barToggle}
              nmAppletCommand = ${if bar == "caelestia-shell" then "nil" else luaString "uwsm app -s b -- nm-applet --indicator"}
              batteryNotifyCommand = ${if isLaptop then luaString "uwsm app -s b -- ${getExe (pkgs.callPackage ./scripts/batterynotify.nix { })}" else "nil"}

              term = ${luaString "${app} ${getExe pkgs.${terminal}}"}
              editor = ${luaString "${app} ${editorExe}"}
              browser = ${luaString "${app} ${browser}"}
              file_manager = ${luaString fileManager}
              file_manager_script = ${luaString "${app} ${getExe fileManagerScript}"}
              launcher = ${luaString launcher}
              caelestia = ${luaString caelestia}
              games = ${luaString (if bar == "caelestia-shell" then "${app} caelestia shell games open" else "${launcher} games")}
              tmux = ${luaString (if bar == "caelestia-shell" then "${app} caelestia shell tmux open" else "${launcher} tmux")}
              music = ${luaString (if bar == "caelestia-shell" then "${app} caelestia shell music open" else "${app} ${getExe (pkgs.callPackage ./scripts/rofimusic.nix { })}")}
              pear = ${luaString "${app} ${getExe pkgs.pear-desktop}"}
              btop = ${luaString (getExe pkgs.btop)}
              clipmanager = ${luaString "${app} ${getExe (pkgs.callPackage ./scripts/clipmanager.nix { })}"}
              gamemode = ${luaString (getExe (pkgs.callPackage ./scripts/gamemode.nix { }))}
              keyboardswitch = ${luaString (getExe (pkgs.callPackage ./scripts/keyboardswitch.nix { }))}
              keybinds_yad = ${luaString "${app} ${getExe (pkgs.callPackage ./scripts/keybinds-yad.nix { inherit host; })}"}
              screen_record = ${luaString (getExe (pkgs.callPackage ./scripts/screen-record.nix { }))}
              screenshot = ${luaString (getExe (pkgs.callPackage ./scripts/screenshot.nix { }))}
              zoom = ${luaString (getExe (pkgs.callPackage ./scripts/zoom.nix { }))}
              night_mode = ${luaString "${backgroundApp} ${getExe pkgs.hyprsunset} --temperature 3500"}
              clipboardTextCommand = ${luaString "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store"}
              clipboardImageCommand = ${luaString "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store"}
              clearClipboardCommand = ${luaString clearClipboardCommand}
              kbdLayout = ${luaString kbdLayout}
              kbdVariant = ${luaString kbdVariant}
              vrr = ${toString (if videoDriver == "nvk" then 0 else 2)}
            '';
          };
        }
      )
    ];
}
