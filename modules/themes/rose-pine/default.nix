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

  # Choose the desired variant: "main", "moon", or "dawn"
  variant = "main";

  # Compute base names for themes
  baseName = if variant == "main" then "rose-pine" else "rose-pine-${variant}";
  kvantumThemeName = "${baseName}-iris";

  # Fetch the Rose Pine Kvantum repository
  rose-pine-kvantum-pkg = pkgs.rose-pine-kvantum;
  kvantumThemeDir = "${rose-pine-kvantum-pkg}/share/Kvantum/themes/${kvantumThemeName}";
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        # Include Rose Pine GTK and icon themes + hyprqt6engine packages
        home.packages = [
          rose-pine-kvantum-pkg
          pkgs.rose-pine-gtk-theme
          pkgs.rose-pine-icon-theme
          pkgs.kdePackages.qtstyleplugin-kvantum
          pkgs.kdePackages.qqc2-desktop-style  # Required for KDE Connect and QML apps
          pkgs.kdePackages.breeze  # Provides Breeze Dark color scheme
          inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        # GTK configuration
        gtk = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          theme = {
            name = baseName;
            package = pkgs.rose-pine-gtk-theme;
          };
          iconTheme = {
            package = pkgs.rose-pine-icon-theme;
            name = "rose-pine";
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

        # Qt configuration with Kvantum
        qt = lib.mkIf (!caelestiaOwnsTheme) {
          enable = true;
          style.name = "kvantum";
        };

        # GNOME dark mode
        dconf.settings = lib.mkIf (!caelestiaOwnsTheme) {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        # Pointer cursor
        home.pointerCursor = {
          gtk.enable = !caelestiaOwnsTheme;
          x11.enable = true;
          package = pkgs.catppuccin-cursors.mochaMauve;
          name = "catppuccin-mocha-mauve-cursors";
          size = 24;
        };

        xdg.configFile = {
          # Kate editor text area uses KTextEditor - separate from Qt widget theming
          "katerc".source = (pkgs.formats.ini { }).generate "katerc" {
            UiSettings.ColorScheme = "Breeze Dark";
            "KTextEditor Renderer" = {
              "Auto Color Theme Selection" = false;
              "Color Theme" = "Breeze Dark";
            };
          };
          # KWrite - same KTextEditor config
          "kwriterc".source = (pkgs.formats.ini { }).generate "kwriterc" {
            UiSettings.ColorScheme = "Breeze Dark";
            "KTextEditor Renderer" = {
              "Auto Color Theme Selection" = false;
              "Color Theme" = "Breeze Dark";
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
              Icons.Theme = "rose-pine";
            };
          };
          # Kvantum configuration
          "Kvantum/${kvantumThemeName}" = lib.mkIf (!caelestiaOwnsTheme) {
            source = kvantumThemeDir;
          };
          "Kvantum/kvantum.kvconfig" = lib.mkIf (!caelestiaOwnsTheme) {
            source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
              General.theme = kvantumThemeName;
            };
          };
          # GTK4 assets for consistency
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
                icon_theme = rose-pine
                color_scheme = ${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors
              }
            '';
          };
        };
      }
    )
  ];
}
