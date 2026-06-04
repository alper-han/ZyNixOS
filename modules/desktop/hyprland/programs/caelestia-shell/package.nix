{
  inputs,
  pkgs,
}:
let
  caelestiaCliPackage =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zynixGamesCatalog = pkgs.callPackage ./scripts/zynix-games-catalog.nix { };
  baseCaelestiaPackage =
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.caelestia-shell.override
      {
        withCli = true;
        caelestia-cli = caelestiaCliPackage;
        extraRuntimeDeps = with pkgs; [
          tmux
          mpv
          procps
          wl-clipboard
          file
          xdg-utils
          exiftool
          mediainfo
          b3sum
          coreutils
          uwsm
          qt6.qtimageformats
          zynixGamesCatalog
        ];
      };
  caelestiaPackage = baseCaelestiaPackage.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
            mkdir -p $out/share/caelestia-shell/modules/zynix
            cp -r ${./qml/modules/zynix}/. $out/share/caelestia-shell/modules/zynix/

            substituteInPlace $out/share/caelestia-shell/shell.qml \
              --replace-fail 'import "modules/drawers"' 'import "modules/drawers"
      import "modules/zynix"'
            substituteInPlace $out/share/caelestia-shell/shell.qml \
              --replace-fail '    Background {}' '    Background {}
          ZynixShellExtensions {}'

            substituteInPlace $out/share/caelestia-shell/modules/launcher/services/Apps.qml \
              --replace-fail '["app2unit", "--", ...entry.command]' '["app2unit", "--", entry.id]'
    '';
  });
in
{
  inherit caelestiaCliPackage caelestiaPackage;
}
