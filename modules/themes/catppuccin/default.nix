{
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    (_: {
      home.packages = [
        pkgs.catppuccin-cursors.mochaMauve
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

    })
  ];
}
