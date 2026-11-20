{ inputs, pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      home.packages = [ inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    }
  ];
}
