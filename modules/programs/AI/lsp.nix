{ pkgs, ... }:
let
  omnisharpLauncher = pkgs.writeShellScriptBin "omnisharp" ''
    exec ${pkgs.omnisharp-roslyn}/bin/OmniSharp "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    clang-tools
    rust-analyzer
    gopls
    typescript-language-server
    pyright
    bash-language-server
    lua-language-server
    yaml-language-server
    omnisharpLauncher
  ];

}
