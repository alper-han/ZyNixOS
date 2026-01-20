{ pkgs, lib, ... }:

let
  inherit (lib) getExe;

  # Import custom actions
  generalActions = import ./actions/general.nix;
  checksumActions = import ./actions/checksum.nix;
  fileinfoActions = import ./actions/fileinfo.nix;
  peazipActions = import ./actions/peazip.nix;

  # Import rofi scripts
  checksum-rofi = pkgs.callPackage ./scripts/checksum-rofi.nix { };
  fileinfo-rofi = pkgs.callPackage ./scripts/fileinfo-rofi.nix { };
  exifinfo-rofi = pkgs.callPackage ./scripts/exifinfo-rofi.nix { };
  mediainfo-rofi = pkgs.callPackage ./scripts/mediainfo-rofi.nix { };
in
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = with pkgs;
    (checksumActions.packages pkgs) ++
    (fileinfoActions.packages pkgs) ++
    (peazipActions.packages pkgs) ++
    [
      checksum-rofi
      fileinfo-rofi
      exifinfo-rofi
      mediainfo-rofi
    ];

  # Thunar Custom Actions
  home-manager.sharedModules = [{
    # Custom Actions XML
    xdg.configFile."Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        ${generalActions.xml}
        ${checksumActions.xml}
        ${fileinfoActions.xml}
        ${peazipActions.xml}
      </actions>
    '';
  }];
}
