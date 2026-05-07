{
  self,
  inputs,
  host,
  lib,
  pkgs,
  overlays,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    consoleKeymap
    kbdLayout
    kbdVariant
    locale
    timezone
    ;
in
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];
  programs = {
    nix-index-database.comma.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  services.xserver = {
    enable = false;
    excludePackages = with pkgs; [ xterm ];
    exportConfiguration = true; # Make sure /etc/X11/xkb is populated so localectl works correctly
    xkb = {
      layout = "${kbdLayout}";
      variant = "${kbdVariant}";
    };
  };

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = "1G";
  };

  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true; # May make rebuilds longer but less size
      trusted-users = [
        "@wheel"
      ];
      accept-flake-config = true;
      substituters = lib.mkForce [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org?priority=20"
        "https://hyprland.cachix.org?priority=30"
        "https://cachix.cachix.org?priority=40"
        "https://cuda-maintainers.cachix.org?priority=60"
        # Upstream cache for xddxdd/nix-cachyos-kernel release branch.
        # Keep low priority because global substituters cannot be scoped per-package.
        "https://attic.xuyh0120.win/lantian?priority=120"
        # "https://nixpkgs-wayland.cachix.org"
        # "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
      warn-dirty = true;
      keep-outputs = false;
      keep-derivations = false;
    };
    # package = pkgs.nixVersions.latest;
  };
  time.timeZone = "${timezone}";
  i18n.defaultLocale = "${locale}";
  documentation.nixos.enable = false;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${locale}";
    LC_IDENTIFICATION = "${locale}";
    LC_MEASUREMENT = "${locale}";
    LC_MONETARY = "${locale}";
    LC_NAME = "${locale}";
    LC_NUMERIC = "${locale}";
    LC_PAPER = "${locale}";
    LC_TELEPHONE = "${locale}";
    LC_TIME = "${locale}";
  };
  environment.variables = {
    templates = "${self}/dev-shells";
    NIXOS_OZONE_WL = "1";

    # These are the defaults, and xdg.enable does set them, but due to load
    # order, they're not set before environment.variables are set, which could
    # cause race conditions.
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 100;
  };

  console.keyMap = "${consoleKeymap}";
  nixpkgs = {
    overlays = builtins.attrValues overlays;
    config = {
      allowUnfree = true;
      # allowUnfreePredicate = _: true;
    };
  };
  system.stateVersion = "26.05"; # Do not change!
}
