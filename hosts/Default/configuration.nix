{ lib, ... }:
let
  vars = import ./variables.nix;
  assertOneOf =
    name: value: allowed:
    lib.assertOneOf name value allowed;
in
assert assertOneOf "terminal" vars.terminal [
  "kitty"
  "alacritty"
];
assert assertOneOf "editor" vars.editor [
  "vscode"
  "kate"
];
assert assertOneOf "fileManager" vars.fileManager [
  "thunar"
  "yazi"
];
assert assertOneOf "displayManager" vars.displayManager [
  "sddm"
  "greetd"
];
assert assertOneOf "shell" vars.shell [
  "bash"
  "zsh"
];
assert assertOneOf "videoDriver" vars.videoDriver [
  "nvidia"
  "amdgpu"
  "intel"
];
assert assertOneOf "powerManager" vars.powerManager [
  "cpufreq"
  "tlp"
  "none"
];
assert assertOneOf "sddmTheme" vars.sddmTheme [
  "astronaut"
  "black_hole"
  "purple_leaves"
];
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core modules
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
    ../../modules/core/flatpak.nix

    # Profile-selected modules
    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/hyprland
    ../../modules/programs/browser/zen-beta
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor}
    ../../modules/programs/file-manager/${vars.fileManager}
    ../../modules/programs/AI
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/cli/fastfetch
    ../../modules/programs/media/discord
    ../../modules/programs/media/pear-desktop
    ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/crossmacro
    ../../modules/programs/misc/kde-connect

    # Optional modules; uncomment to enable.
    # ../../modules/core/virtualisation/qemu-virt-manager.nix # QEMU/KVM virtual machines
    # ../../modules/core/virtualisation/docker.nix # Docker engine
    # ../../modules/core/virtualisation/podman.nix # Podman engine
    # ../../modules/core/ssh.nix # SSH server
    # ../../modules/core/nix-ld.nix # Run selected non-Nix binaries
    # ../../modules/programs/misc/openrgb # RGB controller
    # ../../modules/programs/misc/opensnitch # Application firewall
    # ../../modules/programs/misc/tailscale # Mesh VPN
    # ../../modules/programs/media/davinci-resolve-studio # DaVinci Resolve
    # ../../modules/programs/misc/zapret # Network filtering workaround
    # ../../modules/programs/misc/duplicati # Backup service
    # ../../modules/programs/media/easyeffects # Audio effects
    # ../../modules/programs/media/thunderbird # Thunderbird mail client
  ]
  ++ lib.optional vars.games ../../modules/core/games.nix
  ++ lib.optional (
    vars.isLaptop && vars.powerManager != "none"
  ) ../../modules/programs/misc/${vars.powerManager};
}
