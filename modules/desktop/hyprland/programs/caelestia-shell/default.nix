{
  inputs,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../../hosts/${host}/variables.nix)
    bluetoothSupport
    isLaptop
    terminal
    fileManager
    ;

  caelestiaSettings = import ./settings.nix {
    inherit
      bluetoothSupport
      isLaptop
      terminal
      fileManager
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
          pkgs.libsForQt5.qtstyleplugin-kvantum
          caelestiaPackages.qtenginePackage
          caelestiaPackages.darklyPackage
        ];

        xdg.configFile."uwsm/env.d/50-caelestia-theme".text = import ./uwsm-env.nix {
          inherit pkgs;
          inherit (caelestiaPackages) qtenginePackage darklyPackage;
        };
        xdg.configFile."swappy/config".text = ''
          [Default]
          save_dir=$HOME/Pictures/Screenshots
          save_filename_format=swappy-%Y%m%d-%H%M%S.png
          early_exit=false
          auto_save=false
        '';
        xdg.dataFile."applications/org.quickshell.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Quickshell
          Exec=${caelestiaPackages.caelestiaPackage}/bin/caelestia-shell
          Icon=org.quickshell
          NoDisplay=true
          StartupNotify=false
          Categories=Utility;
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
              enableFuzzel = true;
              enableBtop = true;
              enableGtk = true;
              enableQt = true;
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
