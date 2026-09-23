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
    ripgrep
    tldr
    unrar
    unzip
    wget
    xxd

    # cmatrix
    # cowsay
    # duf
    # dysk
    # gnome-disk-utility
    # glxinfo
    # inxi
    # libnotify
    # lolcat
    # lshw
    # nix-prefetch-scripts
    # nixfmt-rfc-style
    # nwg-displays
    # nvtopPackages.full
    # onefetch
    # pavucontrol
    # pciutils
    # patchelf
    # picard
    # pkg-config
    # rhythmbox
    # socat
    # usbutils
    # uwsm
    # v4l-utils
    # warp-terminal
    # waypaper
    # ytmdl
    # devenv
    # devbox
    # shellify
  ];
}
