{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  environment.systemPackages = with pkgs; [
    # nix-output-monitor
    nvd
    # vulnix
  ];
}
