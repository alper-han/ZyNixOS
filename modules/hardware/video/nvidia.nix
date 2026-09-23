{
  lib,
  config,
  pkgs,
  ...
}:
let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.production; # production , new_feature , stable , latest , beta
in
{
  # Limit the NVIDIA VA-API RDD workaround to Zen, not all Firefox processes.
  home-manager.sharedModules = [
    { programs.zen-browser.env.MOZ_DISABLE_RDD_SANDBOX = "1"; }
  ];

  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    # GBM_BACKEND = "nvidia-drm";
    # WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __GL_MaxFramesAllowed = "1"; # Reduces input lag
    # __GL_SYNC_TO_VBLANK = "0"; # Disable VSync for lower input lag (works with allow_tearing)
  };

  services.xserver.videoDrivers = [ "nvidia" ]; # or "nvidiaLegacy470", etc.
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];
  hardware = {
    nvidia = {
      open = true; # nvdec performance fix
      nvidiaPersistenced = true;
      nvidiaSettings = false;
      powerManagement.enable = true; # This can cause sleep/suspend to fail.
      modesetting.enable = true;
      package = nvidiaDriverChannel;
    };
    graphics = {
      enable32Bit = true;
      extraPackages = [
        pkgs.nvidia-vaapi-driver
        pkgs.libva-vdpau-driver
        pkgs.libvdpau-va-gl
      ];
    };
  };
  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaSupport = true;
  };
}
