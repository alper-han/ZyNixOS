{ pkgs, ... }:
{
  programs.mtr.enable = true;

  # Shared CLI tools; host applications belong in hosts/Default/host-packages.nix.
  environment.systemPackages = with pkgs; [
    android-tools
    appimage-run
    fd
    ffmpeg # Terminal Video / Audio Editing
    file
    fzf
    gh
    git
    jq
    killall
    libjxl
    lm_sensors
    microfetch
    ncdu # or use gdu
    ripgrep
    tldr
    unrar
    unzip
    wget
    xxd

    # cmatrix # Matrix Movie Effect In Terminal
    # cowsay # Great Fun Terminal Program
    # duf # Utility For Viewing Disk Usage In Terminal
    # dysk # Disk space util nice formattting
    # gnome-disk-utility # Disk Partitioning and Mounting Utility
    # glxinfo # needed for inxi diag util
    # inxi # CLI System Information Tool
    # libnotify # For Notifications
    # lolcat # Add Colors To Your Terminal Command Output
    # lshw # Detailed Hardware Information
    # nix-prefetch-scripts # Not used - nix flake prefetch is preferred
    # nixfmt-rfc-style # Nix Formatter
    # nwg-displays # configure monitor configs via GUI
    # nvtopPackages.full
    # onefetch # provides zsaneyos build info on current system
    # pavucontrol # For Editing Audio Levels & Devices
    # pciutils # Collection Of Tools For Inspecting PCI Devices
    # patchelf # Enable only when binary patching is needed
    # picard # For Changing Music Metadata & Getting Cover Art
    # pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    # rhythmbox # audio player
    # socat # Needed For Screenshots
    # usbutils # Good Tools For USB Devices
    # uwsm # Universal Wayland Session Manager (optional must be enabled)
    # v4l-utils # Used For Things Like OBS Virtual Camera
    # warp-terminal # Terminal with AI support build in
    # waypaper # Change wallpaper
    # ytmdl # Tool For Downloading Audio From YouTube
    # devenv
    # devbox
    # shellify
  ];
}
