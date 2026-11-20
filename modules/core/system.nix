{
  inputs,
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    consoleKeymap
    kbdLayout
    kbdVariant
    username
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
      enableSSHSupport = false;
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
    settings = {
      auto-optimise-store = true; # May make rebuilds longer but less size
      # Only root is a trusted Nix user. Normal users can use the daemon without
      # being able to inject arbitrary settings or substitute-store closures.
      trusted-users = [ "root" ];
      accept-flake-config = false;
      # Every third-party substituter below has a matching pinned public key in
      # trusted-public-keys. Keep additions explicit and remove a cache and its
      # key together; a URL alone is never a trust decision.
      substituters = lib.mkForce [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org?priority=20"
        # "https://nixpkgs-wayland.cachix.org"
        # "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  console.colors = [
    "1C2133"
    "F27983"
    "A6E3A1"
    "F9E2AF"
    "89B4FA"
    "F38BA8"
    "94E2D5"
    "BAC2DE"
    "414559"
    "F27983"
    "A6E3A1"
    "F9E2AF"
    "89B4FA"
    "F38BA8"
    "94E2D5"
    "A6ADC8"
  ];

  nixpkgs = {
    # Overlay order lives in flake.nix.
    config = {
      allowUnfreePredicate =
        pkg:
        let
          name = lib.getName pkg;
        in
        lib.hasPrefix "cuda" name
        || lib.hasPrefix "libcu" name
        || lib.hasPrefix "libnv" name
        || lib.hasPrefix "cudnn" name
        || name == "libnpp"
        || name == "nccl"
        || name == "cccl"
        || builtins.elem name [
          "discord"
          "discord-unwrapped"
          "github-desktop"
          "jetbrains-rider"
          "libsciter"
          "nvidia-x11"
          "rider"
          "steam"
          "steam-unwrapped"
          "steam-original"
          "steam-run"
          "unrar"
          "vscode"
        ];
    };
  };
  system.stateVersion = "26.11";
}
