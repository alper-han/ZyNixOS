{ pkgs, ... }:
{
  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    appimage-run
    fd
    ffmpeg
    file
    fzf
    gh
    git
    jq
    killall
    libjxl
    lm_sensors
    microfetch
    ncdu
    p7zip
    ripgrep
    tldr
    unrar
    unzip
    wget
    xxd
    zstd
  ];
}
