{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      enablePkexecWrapper = true;
    };
    sudo.execWheelOnly = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false;
      packages = [ pkgs.apparmor-profiles ];
    };

    protectKernelImage = true;
  };
}
