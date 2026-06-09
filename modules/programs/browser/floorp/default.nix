{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    (_: {
      programs.floorp = {
        enable = true;
        policies = import ./policies.nix { inherit lib; };
        languagePacks = [
          "en-GB"
          "en-US"
        ];
        profiles = {
          default = {
            # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
            id = 0; # 0 is the default profile; see also option "isDefault"
            name = "default"; # name as listed in about:profiles
            isDefault = true; # can be omitted; true if profile ID is 0
            settings = import ./settings.nix { inherit lib; };
            bookmarks = import ../bookmarks.nix;
            search = import ./search.nix { inherit pkgs; };
            # userChrome = builtins.readFile ./userChrome.css;
            # userContent = builtins.readFile ./userContent.css;
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
