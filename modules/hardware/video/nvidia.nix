{
  lib,
  config,
  pkgs,
  ...
}:
let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.new_feature;
  nvidiaDriverPackage = nvidiaDriverChannel // {
    open = nvidiaDriverChannel.open.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/24e68a854f50e2de5b7ead18bd4d28d22566c005.patch";
          hash = "sha256-Sywd2R0oublLLkr015Ke0R7CXqhBplh+j+XFQXcKdhk=";
        })
      ];
    });
  };
in
{
  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    # GBM_BACKEND = "nvidia-drm";
    # WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __GL_MaxFramesAllowed = "1"; # Reduces input lag
    # __GL_SYNC_TO_VBLANK = "0"; # Disable VSync for lower input lag (works with allow_tearing)
  };

  # Load nvidia driver for Xorg and Wayland
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
      package = nvidiaDriverPackage;
    };
    graphics = {
      enable = true;
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
