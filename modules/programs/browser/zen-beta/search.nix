{ pkgs, ... }:
{
  force = true;
  default = "ddg";
  privateDefault = "ddg";
  order = [
    "ddg"
    "Brave"
    "NixOS Packages"
    "NixOS Options"
    "NixOS Wiki"
    "Home Manager Options"
    "google"
  ];
  engines =
    let
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    in
    {
      "Brave" = {
        urls = [
          {
            template = "https://search.brave.com/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
        definedAliases = [ "@br" ];
        updateInterval = 24 * 60 * 60 * 1000;
      };
      "NixOS Packages" = {
        inherit icon;
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "@np"
          "@nixpkgs"
        ];
      };
      "NixOS Options" = {
        inherit icon;
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "@no"
          "@nixopts"
        ];
      };
      "NixOS Wiki" = {
        inherit icon;
        urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@nw" ];
      };
      "Home Manager" = {
        inherit icon;
        urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; } ];
        definedAliases = [
          "@hm"
          "@home"
          "'homeman"
        ];
      };
      "My NixOS" = {
        inherit icon;
        urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
        definedAliases = [
          "@mn"
          "@nx"
          "@mynixos"
        ];
      };
      "youtube" = {
        urls = [ { template = "https://youtube.com/results?search_query={searchTerms}"; } ];
        definedAliases = [ "@yt" ];
      };
      "bing".metaData.hidden = true;
      "Ebay".metaData.hidden = true;
      "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
    };
}
