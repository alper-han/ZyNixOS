{ pkgs, inputs, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = [
          pkgs.dracula-theme
          pkgs.kdePackages.qtstyleplugin-kvantum
          pkgs.kdePackages.qqc2-desktop-style  # Required for KDE Connect and QML apps
          pkgs.kdePackages.breeze  # Provides Breeze Dark color scheme
          inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Dracula";
            color-scheme = "prefer-dark";
          };
        };

        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.rose-pine-cursor;
          name = "BreezeX-RosePine-Linux";
          size = 24;
        };

        qt = {
          enable = true;
          style.name = "kvantum";
        };

        gtk = {
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

        home.sessionVariables = {
          ADW_COLOR_SCHEME = "prefer-dark"; # Libadwaita
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
          "kdeglobals".source = (pkgs.formats.ini { }).generate "kdeglobals" {
            General = {
              ColorScheme = "BreezeDark";
              widgetStyle = "kvantum";
            };
            KDE.widgetStyle = "kvantum";
            Icons.Theme = "Papirus-Dark";
          };
          # GTK4 theming
          "gtk-4.0/assets" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
          };
          "gtk-4.0/gtk.css" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
          };
          "gtk-4.0/gtk-dark.css" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
          };
          # hyprqt6engine config for Qt6/KDE app theming
          "hypr/hyprqt6engine.conf".text = ''
            theme {
              style = kvantum
              icon_theme = Papirus-Dark
              color_scheme = ${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors
            }
          '';
        };
      }
    )
  ];
}
