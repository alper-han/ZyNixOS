{
  lib,
  pkgs,
  config,
  ...
}:
let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.latest; # stable, latest, beta, etc.
in
{
  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    # GBM_BACKEND = "nvidia-drm";
    # WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_MaxFramesAllowed = "1"; # Reduces input lag
    __GL_SYNC_TO_VBLANK = "0"; # Disable VSync for lower input lag (works with allow_tearing)
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ]; # or "nvidiaLegacy470", etc.
  boot.kernelParams = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "nvidia.NVreg_RegistryDwords=RmEnableAggressiveVblank=1" # Experimental: reduce latency
  ];
  hardware = {
    nvidia = {
      open = true;
      # nvidiaPersistenced = true;
      nvidiaSettings = true;
      powerManagement.enable = true; # This can cause sleep/suspend to fail.
      modesetting.enable = true;
      package = nvidiaDriverChannel;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaSupport = true;
  };
}
