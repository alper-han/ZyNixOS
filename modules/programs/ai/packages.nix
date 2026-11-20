{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    nixd
    chromium
  ];
}
