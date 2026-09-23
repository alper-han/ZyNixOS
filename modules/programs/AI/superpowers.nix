{ ... }:
{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      let
        # Fetch the pinned upstream release without vendoring its files.
        superpowersPackage = pkgs.stdenvNoCC.mkDerivation {
          pname = "superpowers";
          version = "6.4.1";
          src = pkgs.fetchFromGitHub {
            owner = "obra";
            repo = "superpowers";
            rev = "5bf4e78011075bcfc0dc295f0724994cd123ee71";
            hash = "sha256-rgeJhjQyABYlhlyFRmgyhbZmmmIPPNkch4CXyTkGEyM=";
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p "$out"
            cp -R . "$out"
          '';
        };
        superpowersPath = "${superpowersPackage}";
        superpowersExtension = builtins.toJSON superpowersPath;
      in
      {
        # Update the seeded extension path without replacing user entries or retaining old store paths.
        home.activation.ompSuperpowers = lib.mkForce {
          before = [ ];
          after = [ "ompConfig" ];
          data = ''
            if [ -f "$HOME/.omp/agent/config.yml" ]; then
              run ${lib.getExe pkgs.yq-go} -i \
                '.extensions = (((.extensions // []) | map(select(test("^/nix/store/[^/]+-superpowers-[^/]+$") | not))) + [${superpowersExtension}] | unique)' \
                "$HOME/.omp/agent/config.yml"
            fi
          '';
        };
      }
    )
  ];
}
