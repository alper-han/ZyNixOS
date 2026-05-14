{
  inputs,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../../hosts/${host}/variables.nix)
    bluetoothSupport
    defaultWallpaper
    fileManager
    isLaptop
    terminal
    ;

  wallpapersDir = ../../../../themes/wallpapers;
  defaultWallpaperPath = "${wallpapersDir}/${defaultWallpaper}";

  caelestiaSettings = import ./settings.nix {
    inherit
      bluetoothSupport
      fileManager
      isLaptop
      terminal
      ;
  };
  caelestiaShellJson = pkgs.writeText "caelestia-shell.json" (builtins.toJSON caelestiaSettings);
  caelestiaThemePostHook = import ./theme-post-hook.nix { inherit pkgs; };
  caelestiaPackages = import ./package.nix { inherit inputs pkgs; };
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        imports = [
          inputs.caelestia-shell.homeManagerModules.default
        ];

        home.packages = [
          pkgs.adw-gtk3
          pkgs.papirus-folders
          pkgs.papirus-icon-theme
          pkgs.qtengine
        ];

        xdg.configFile."uwsm/env.d/50-caelestia-theme".text = import ./uwsm-env.nix { inherit pkgs; };

        programs.caelestia = {
          enable = true;
          package = caelestiaPackages.caelestiaPackage;
          cli.package = caelestiaPackages.caelestiaCliPackage;
          systemd.enable = false;
          cli = {
            enable = true;
            settings.theme = {
              enableTerm = true;
              enableHypr = true;
              enableDiscord = true;
              enableSpicetify = true;
              enablePandora = true;
              enableFuzzel = true;
              enableBtop = true;
              enableNvtop = true;
              enableHtop = true;
              enableGtk = true;
              enableQt = true;
              enableWarp = true;
              enableChromium = true;
              enableZed = true;
              enableCava = true;
              iconTheme = "Papirus-Dark";
              iconThemeLight = "Papirus";
              iconThemeDark = "Papirus-Dark";
              postHook = toString caelestiaThemePostHook;
            };
          };
        };

        home.activation.caelestiaWritableConfig = import ./activation.nix {
          inherit
            caelestiaShellJson
            config
            defaultWallpaperPath
            lib
            pkgs
            ;
        };
      }
    )
  ];
}
