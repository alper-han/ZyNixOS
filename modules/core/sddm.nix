{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) sddmTheme;
  themeConfigs = {
    black_hole = {
      ScreenPadding = "";
      FormPosition = "center";
    };
    astronaut = {
      PartialBlur = "false";
      FormPosition = "center";
    };
    purple_leaves = {
      PartialBlur = "false";
    };
  };
  currentThemeConfig =
    if builtins.hasAttr sddmTheme themeConfigs then themeConfigs.${sddmTheme} else { };
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = sddmTheme;
    themeConfig = currentThemeConfig;
  };
  sddmDependencies = [
    sddm-astronaut
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtvirtualkeyboard
    pkgs.catppuccin-cursors.mochaMauve
  ];
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
    autoNumlock = true;
    extraPackages = sddmDependencies;
    settings.Theme.CursorTheme = "catppuccin-mocha-mauve-cursors";
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = sddmDependencies;
}
