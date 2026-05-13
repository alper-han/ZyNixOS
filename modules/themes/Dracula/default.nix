{
  pkgs,
  inputs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) bar;
  caelestiaOwnsTheme = bar == "caelestia-shell";
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = [
          pkgs.dracula-theme
          pkgs.kdePackages.qtstyleplugin-kvantum
          pkgs.kdePackages.qqc2-desktop-style # Required for KDE Connect and QML apps
          pkgs.kdePackages.breeze # Provides Breeze Dark color scheme
          inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        dconf.settings = lib.mkIf (!caelestiaOwnsTheme) {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Dracula";
            color-scheme = "prefer-dark";
          };
        };

        home.pointerCursor = {
          gtk.enable = !caelestiaOwnsTheme;
          x11.enable = true;
          package = pkgs.catppuccin-cursors.mochaMauve;
          name = "catppuccin-mocha-mauve-cursors";
          size = 24;
        };

        qt = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          style.name = "kvantum";
        };

        gtk = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          gtk3.extraConfig = {
            "gtk-application-prefer-dark-theme" = "1";
          };
          gtk4.extraConfig = {
            "gtk-application-prefer-dark-theme" = "1";
          };
        };

        home.sessionVariables = lib.mkIf (!caelestiaOwnsTheme) {
          ADW_COLOR_SCHEME = "prefer-dark"; # Libadwaita
        };

        xdg.configFile = {
          # Kate editor text area uses KTextEditor - separate from Qt widget theming
          "katerc" = lib.mkIf (!caelestiaOwnsTheme) {
            source = (pkgs.formats.ini { }).generate "katerc" {
              UiSettings.ColorScheme = "Breeze Dark";
              "KTextEditor Renderer" = {
                "Auto Color Theme Selection" = false;
                "Color Theme" = "Breeze Dark";
              };
            };
          };
          # KWrite - same KTextEditor config
          "kwriterc" = lib.mkIf (!caelestiaOwnsTheme) {
            source = (pkgs.formats.ini { }).generate "kwriterc" {
              UiSettings.ColorScheme = "Breeze Dark";
              "KTextEditor Renderer" = {
                "Auto Color Theme Selection" = false;
                "Color Theme" = "Breeze Dark";
              };
            };
          };
          # Global KDE dark mode - triggers auto-detection in KTextEditor apps
          "kdeglobals" = lib.mkIf (!caelestiaOwnsTheme) {
            source = (pkgs.formats.ini { }).generate "kdeglobals" {
              General = {
                ColorScheme = "BreezeDark";
                widgetStyle = "kvantum";
              };
              KDE.widgetStyle = "kvantum";
              Icons.Theme = "Papirus-Dark";
            };
          };
          # GTK4 theming
          "gtk-4.0/assets" = lib.mkIf (!caelestiaOwnsTheme) {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
          };
          "gtk-4.0/gtk.css" = lib.mkIf (!caelestiaOwnsTheme) {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
          };
          "gtk-4.0/gtk-dark.css" = lib.mkIf (!caelestiaOwnsTheme) {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
          };
          # hyprqt6engine config for Qt6/KDE app theming
          "hypr/hyprqt6engine.conf" = lib.mkIf (!caelestiaOwnsTheme) {
            text = ''
              theme {
                style = kvantum
                icon_theme = Papirus-Dark
                color_scheme = ${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors
              }
            '';
          };
        };
      }
    )
  ];
}
