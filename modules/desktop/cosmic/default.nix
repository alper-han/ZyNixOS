{ lib, pkgs, ... }:
{
  imports = [ ../../themes/Catppuccin ];

  services.geoclue2.enable = lib.mkForce false;

  services.displayManager.defaultSession = "cosmic";

  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  services = {
    tlp.enable = lib.mkForce false; # COSMIC has integrated power/session management.
    auto-cpufreq.enable = lib.mkForce false; # COSMIC has integrated power/session management.
  };

  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaMauve
    papirus-icon-theme
  ];
}
