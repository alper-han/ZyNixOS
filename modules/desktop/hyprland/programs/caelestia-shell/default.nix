{
  inputs,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../../hosts/${host}/variables.nix)
    bluetoothSupport
    fileManager
    isLaptop
    terminal
    ;

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
        xdg.configFile."swappy/config".text = ''
          [Default]
          save_dir=$HOME/Pictures/Screenshots
          save_filename_format=swappy-%Y%m%d-%H%M%S.png
          early_exit=false
          auto_save=false
        '';

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
            lib
            pkgs
            ;
        };
      }
    )
  ];
}
