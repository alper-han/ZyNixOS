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
    # ../../modules/programs/misc/duplicati
    # ../../modules/programs/media/easyeffects
    # ../../modules/programs/media/thunderbird
  ]
  ++ lib.optional vars.games ../../modules/core/games.nix
  ++ lib.optional (
    vars.isLaptop && vars.powerManager != "none"
  ) ../../modules/programs/misc/${vars.powerManager};
}
