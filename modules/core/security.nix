{ ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      enablePkexecWrapper = true;
    };
    sudo.execWheelOnly = true;
    protectKernelImage = true;
  };
}
