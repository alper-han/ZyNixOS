{ pkgs, ... }:
{
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
    DOTNET_ROOT_X64 = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };

  environment.systemPackages = with pkgs; [
    nodejs
    nixd
    chromium
  ];
}
