{
  pkgs,
  inputs,
  lib,
  host,
  ...
}:
let
  variant = "mocha";
  accent = "mauve";
  catppuccin-kvantum-pkg = pkgs.catppuccin-kvantum.override { inherit variant accent; };
  catppuccin = "catppuccin-${variant}-${accent}";
  inherit (import ../../../hosts/${host}/variables.nix) bar;
  caelestiaOwnsTheme = bar == "caelestia-shell";
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = [
          pkgs.adw-gtk3
          pkgs.papirus-icon-theme
          catppuccin-kvantum-pkg
          pkgs.kdePackages.qtstyleplugin-kvantum
          pkgs.kdePackages.qqc2-desktop-style # Required for KDE Connect and QML apps
          pkgs.kdePackages.breeze # Provides Breeze Dark color scheme
          inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        qt = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          style.name = "kvantum";
        };
        home.sessionVariables = lib.mkIf (!caelestiaOwnsTheme) {
          ADW_COLOR_SCHEME = "prefer-dark"; # Libadwaita
        };
        gtk = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          theme = {
            name = "${catppuccin}-compact";
            package = pkgs.catppuccin-gtk.override {
              variant = variant;
              accents = [ accent ];
              size = "compact";
            };
          };
          iconTheme = {
            # package = pkgs.adwaita-icon-theme;
            # name = "Adwaita";
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
          gtk3.extraConfig = {
            "gtk-application-prefer-dark-theme" = "1";
          };
          gtk4.extraConfig = {
            "gtk-application-prefer-dark-theme" = "1";
          };
        };

        dconf.settings = lib.mkIf (!caelestiaOwnsTheme) {
          "org/gnome/desktop/interface" = {
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
          "Kvantum/${catppuccin}" = {
            source = "${catppuccin-kvantum-pkg}/share/Kvantum/${catppuccin}";
          };
          "Kvantum/kvantum.kvconfig" = {
            source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
              General.theme = catppuccin;
            };
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
