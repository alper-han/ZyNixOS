{ lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ../validation.nix
    ./hardware-configuration.nix
    ./hardware-policy.nix
    ./host-packages.nix

    ../../modules/scripts
    ../../modules/core/shell-common.nix
    ../../modules/core/boot.nix
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/${vars.displayManager}.nix
    ../../modules/core/security.nix
    ../../modules/core/ananicy.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/themes/wallpaper-bank.nix
    ../../modules/core/dns.nix

    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/hyprland
    ../../modules/programs/browser/zen-beta
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor}
    ../../modules/programs/file-manager/${vars.fileManager}
    ../../modules/programs/ai
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/btop
    ../../modules/programs/cli/fastfetch
    ../../modules/programs/media/discord
    ../../modules/programs/media/pear-desktop
    ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/crossmacro
    ../../modules/programs/misc/kde-connect

    # ../../modules/programs/cli/lazygit
    # ../../modules/programs/cli/cava
    # ../../modules/programs/misc/lact
    # ../../modules/core/flatpak.nix
    # ../../modules/core/virtualisation/qemu-virt-manager.nix
    # ../../modules/core/virtualisation/docker.nix
    # ../../modules/core/virtualisation/podman.nix
    # ../../modules/core/ssh.nix
    # ../../modules/core/nix-ld.nix
    # ../../modules/programs/misc/openrgb
    # ../../modules/programs/misc/opensnitch
    # ../../modules/programs/misc/tailscale
    # ../../modules/programs/media/davinci-resolve-studio
    # ../../modules/programs/misc/zapret
    # ../../modules/programs/media/easyeffects
    # ../../modules/programs/media/thunderbird
  ]
  ++ lib.optional (vars ? games && vars.games) ../../modules/core/games.nix
  ++ lib.optional (
    vars.isLaptop && vars.powerManager != "none"
  ) ../../modules/programs/misc/${vars.powerManager};
}
