{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (_: {
      services.easyeffects = {
        enable = true;
      };
    })
  ];
}
