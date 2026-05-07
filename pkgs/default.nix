{ host, pkgs, ... }:
{
  # these will be overlayed in nixpkgs automatically.
  # for example: environment.systemPackages = with pkgs; [pokego];
  #  pokego = pkgs.callPackage ./pokego.nix { };

  rider-fhs = pkgs.callPackage ./jetbrains/rider-fhs.nix { };
  rider-fhsWithPackages = extraTargetPkgs: pkgs.callPackage ./jetbrains/rider-fhs.nix { inherit extraTargetPkgs; };
}
