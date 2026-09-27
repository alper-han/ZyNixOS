{ lib, ... }:
{
  home-manager.sharedModules = [
    (_: {
      services.easyeffects = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
