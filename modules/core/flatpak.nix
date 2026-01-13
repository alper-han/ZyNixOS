{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
  services = {
    flatpak = {
      enable = true;
      packages = [
        "com.github.tchx84.Flatseal" # Manage flatpak permissions - should always have this
        "io.github.flattool.Warehouse" # Manage flatpaks, clean data, remove flatpaks and deps
      ];
      update.onActivation = true;
    };
  };
}
