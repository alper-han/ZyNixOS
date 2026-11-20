{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    username
    isLaptop
    terminal
    editor
    fileManager
    defaultWallpaper
    kbdLayout
    kbdVariant
    ;
  browser = "zen-beta";

  wallpapersDir = ../../themes/wallpapers;
  defaultWallpaperPath = "${wallpapersDir}/${defaultWallpaper}";

in
{
  imports = [
    ../../themes/catppuccin
    ./programs/caelestia-shell
  ];

  services.displayManager.defaultSession = "hyprland-uwsm";
  services.upower.enable = isLaptop;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  programs.gpu-screen-recorder.enable = true;

  # Keep portals on the NixOS side. A Home Manager xdg.portal block points
  # NIX_XDG_DESKTOP_PORTAL_DIR at the user profile, hiding the system portals
  # (hyprland, gnome-keyring) from xdg-desktop-portal.
  xdg.portal = {
    enable = true;
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

  home-manager.sharedModules =
    let
      inherit (lib) getExe getExe';
    in
    [
      (
        { config, ... }:
        {
          services.hyprpolkitagent.enable = true;

          home.packages = (
            with pkgs;
            [
              brightnessctl
              cliphist
              fuzzel
              grim
              grimblast
              hyprpicker
              libnotify
              pamixer
              pavucontrol
              playerctl
              swappy
              wl-clipboard
            ]
          );

          # Caelestia owns the wallpaper.
          systemd.user.tmpfiles.rules = [
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
            export CLUTTER_BACKEND=wayland
            export ELECTRON_OZONE_PLATFORM_HINT=auto
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM="wayland;xcb"
            export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
            export QT_AUTO_SCREEN_SCALE_FACTOR=1
            export QT_ENABLE_HIGHDPI_SCALING=1
            export XCURSOR_THEME=catppuccin-mocha-mauve-cursors
            export XCURSOR_SIZE=${toString config.home.pointerCursor.size}
          '';

          xdg.configFile."uwsm/env-hyprland".text = ''
            export HYPRCURSOR_THEME=catppuccin-mocha-mauve-cursors
            export HYPRCURSOR_SIZE=${toString config.home.pointerCursor.size}
          '';

          xdg.configFile."systemd/user/xdg-desktop-portal-gtk.service.d/caelestia-theme.conf" = {
            text = ''
              [Service]
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
            "hypr/host-monitors.lua" =
              let
                hostMonitors = ./lua/monitors/${host}.lua;
              in
              if builtins.pathExists hostMonitors then
                { source = hostMonitors; }
              else
                { text = "-- No host-specific monitor rules for ${host}.\n"; };
            "hypr/variables.lua".text =
              let
                luaString = value: builtins.toJSON value;
                editorExe =
                  if editor == "vscode" then getExe' pkgs.vscode "code" else getExe' pkgs.kdePackages.kate "kate";
                app = "uwsm app --";
                backgroundApp = "uwsm app -s b --";
                serviceApp = "uwsm app -s s --";
                fileManagerCommand =
                  if fileManager == "yazi" then
                    "${app} ${getExe pkgs.${terminal}} -- ${getExe' pkgs.yazi "yazi"}"
                  else
                    "${app} thunar";
                caelestia = "${app} caelestia";
                shellCommand = "${serviceApp} caelestia shell -d";
                shellToggle = "pkill -f '[q]uickshell -p /nix/store/[^ ]*caelestia-shell[^ ]*/share/caelestia-shell -n -d$' || ${shellCommand}";
                clearClipboardCommand = "${app} ${getExe' pkgs.coreutils "rm"} -f \${XDG_CACHE_HOME:-\$HOME/.cache}/cliphist/db";
              in
              ''
                mainMod = "SUPER"
                shell_command = ${luaString shellCommand}
                shell_toggle = ${luaString shellToggle}

                term = ${luaString "${app} ${getExe pkgs.${terminal}}"}
                editor = ${luaString "${app} ${editorExe}"}
                browser = ${luaString "${app} ${browser}"}
                file_manager = ${luaString fileManagerCommand}
                caelestia = ${luaString caelestia}
                games = ${luaString "${app} caelestia shell games open"}
                tmux = ${luaString "${app} caelestia shell tmux open"}
                music = ${luaString "${app} caelestia shell music open"}
                kopuz = ${luaString "${app} kopuz"}
                btop = ${luaString (getExe config.programs.btop.package)}
                screenshot = ${luaString (getExe (pkgs.callPackage ./scripts/screenshot.nix { }))}
                night_mode = ${luaString "${backgroundApp} ${getExe pkgs.hyprsunset} --temperature 3500"}
                clipboardTextCommand = ${luaString "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store"}
                clipboardImageCommand = ${luaString "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store"}
                clearClipboardCommand = ${luaString clearClipboardCommand}
                kbdLayout = ${luaString kbdLayout}
                kbdVariant = ${luaString kbdVariant}
                vrr = 2
              '';
          };
        }
      )
    ];
}
