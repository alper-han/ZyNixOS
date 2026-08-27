{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # environment.systemPackages = with pkgs; [inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default];
  home-manager.sharedModules = [
    (_: {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        env = {
          MOZ_DISABLE_RDD_SANDBOX = "1";
        };
        policies = import ./policies.nix { inherit lib; };
        languagePacks = [
          "tr-TR"
          "en-US"
        ];
        profiles = {
          default = {
            id = 0; # 0 is the default profile; see also option "isDefault"
            name = "default"; # name as listed in about:profiles
            isDefault = true; # can be omitted; true if profile ID is 0
            settings = import ./settings.nix { inherit lib; };
            bookmarks = import ../bookmarks.nix;
            search = import ./search.nix { inherit pkgs; };
            userChrome = builtins.readFile ./userChrome.css;
            userContent = builtins.readFile ./userContent.css;
            extraConfig = ''
              ${builtins.readFile "${inputs.betterfox}/Fastfox.js"}
              ${builtins.readFile "${inputs.betterfox}/Peskyfox.js"}
              ${builtins.readFile "${inputs.betterfox}/Securefox.js"}
              ${builtins.readFile "${inputs.betterfox}/Smoothfox.js"}

            '';
          };
        };
      };
    })
  ];
}
