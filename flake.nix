{
  description = "A simple flake for an atomic system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    thunderbird-catppuccin = {
      url = "github:catppuccin/thunderbird";
      flake = false;
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      customOverlays = import ./overlays;
      overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
        customOverlays.modifications
      ];
      configuredHosts = nixpkgs.lib.filterAttrs (
        host: type: type == "directory" && builtins.pathExists ./hosts/${host}/hardware-configuration.nix
      ) (builtins.readDir ./hosts);
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          modules = [
            ({ ... }: { nixpkgs.overlays = overlays; })
            ./hosts/${host}/configuration.nix
          ];
          specialArgs = {
            inherit inputs host;
          };
        };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      checks = forAllSystems (
        _system:
        nixpkgs.lib.mapAttrs' (
          host: _:
          nixpkgs.lib.nameValuePair "nixos-${host}"
            self.nixosConfigurations.${host}.config.system.build.toplevel
        ) configuredHosts
      );
      nixosConfigurations = nixpkgs.lib.mapAttrs (host: _: mkHost host) configuredHosts;
    };
}
