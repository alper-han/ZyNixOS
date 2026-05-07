{ pkgs, ... }:
{
  # kdePackages.kate ships both the kate and kwrite binaries.
  home-manager.sharedModules = [ (_: { home.packages = with pkgs; [ kdePackages.kate ]; }) ];
}
