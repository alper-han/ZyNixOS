{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # settings.nix marks enforced prefs as { Value; Status = "locked"; }. That shape only
  # means something inside enterprise policies, so split it: locked prefs go to
  # policies.Preferences, and the profile's user.js gets the bare values.
  allSettings = import ./settings.nix { inherit lib; };
  isLocked = value: builtins.isAttrs value && value ? Status;
  basePolicies = import ./policies.nix { inherit lib; };
  policies = basePolicies // {
    # Prefs already declared in policies.nix keep their own entry.
    Preferences = lib.filterAttrs (_: isLocked) allSettings // basePolicies.Preferences;
  };
  profileSettings = lib.mapAttrs (_: value: if isLocked value then value.Value else value) allSettings;
in
{
  # environment.systemPackages = with pkgs; [inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default];
  home-manager.sharedModules = [
    (_: {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        inherit policies;
        languagePacks = [
          "tr-TR"
          "en-US"
        ];
        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            settings = profileSettings;
            bookmarks = import ./bookmarks.nix;
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
