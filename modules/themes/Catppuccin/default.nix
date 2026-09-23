{
  pkgs,
  ...
}:
let
  variant = "mocha";
  accent = "mauve";
  catppuccin-kvantum-pkg = pkgs.catppuccin-kvantum.override { inherit variant accent; };
  catppuccin = "catppuccin-${variant}-${accent}";
in
{
  home-manager.sharedModules = [
    (_: {
      home.packages = [
        pkgs.catppuccin-cursors.mochaMauve
        catppuccin-kvantum-pkg
        pkgs.kdePackages.qtstyleplugin-kvantum
        pkgs.kdePackages.qqc2-desktop-style
      ];

      home.pointerCursor = {
        enable = true;
        gtk.enable = false;
        x11.enable = true;
        package = pkgs.catppuccin-cursors.mochaMauve;
        name = "catppuccin-mocha-mauve-cursors";
        size = 24;
      };

      xdg.configFile = {
        "Kvantum/${catppuccin}" = {
          source = "${catppuccin-kvantum-pkg}/share/Kvantum/${catppuccin}";
        };
        "Kvantum/kvantum.kvconfig" = {
          source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
            General.theme = catppuccin;
          };
        };
      };
    })
  ];
}
