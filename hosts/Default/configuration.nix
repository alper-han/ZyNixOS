{ lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules
    ../../modules/scripts
    ../../modules/core/boot.nix
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/${vars.displayManager}.nix # Set display-manager defined in variables.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    # ../../modules/core/ssh.nix
    # ../../modules/core/flatpak.nix
    # ../../modules/core/virtualisation.nix
    # ../../modules/core/nix-ld.nix
    # ../../modules/core/dns.nix

    # Optional
    ../../modules/hardware/video/${vars.videoDriver}.nix # Enable gpu drivers defined in variables.nix
    ../../modules/desktop/${vars.desktop} # Set window manager defined in variables.nix
    ../../modules/programs/browser/${vars.browser} # Set browser defined in variables.nix
    ../../modules/programs/terminal/${vars.terminal} # Set terminal defined in variables.nix
    ../../modules/programs/editor/${vars.editor} # Set editor defined in variables.nix
    # ../../modules/programs/cli/${vars.tuiFileManager} # Set file-manager defined in variables.nix
    # ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/cli/fastfetch
    ../../modules/programs/media/discord
    ../../modules/programs/media/youtube-music
    ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/thunar
    ../../modules/programs/misc/crossmacro
    ../../modules/programs/misc/kde-connect
    # ../../modules/programs/misc/tailscale
    # ../../modules/programs/misc/lact # GPU fan, clock and power configuration
    # ../../modules/programs/media/davinci-resolve-studio
    # ../../modules/programs/misc/zapret
    # ../../modules/programs/misc/duplicati
    # ../../modules/programs/media/spicetify
    # ../../modules/programs/media/thunderbird
  ]
  ++ lib.optional (vars.games == true) ../../modules/core/games.nix
  ++ lib.optional (vars.isLaptop && vars.powerManager != "none" && vars.desktop == "hyprland") ../../modules/programs/misc/${vars.powerManager};
}
