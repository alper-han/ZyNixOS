{
  lib,
  config,
  pkgs,
  ...
}:
let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.latest; # production , new_feature , stable , latest , beta
in
{
  # Limit the NVIDIA VA-API RDD workaround to Zen, not all Firefox processes.
  home-manager.sharedModules = [
    { programs.zen-browser.env.MOZ_DISABLE_RDD_SANDBOX = "1"; }
  ];

  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
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
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };
  };
  # No global cudaSupport: across this closure it only rebuilt OBS without
  # benefit. GPU-aware variants are picked per package (btop, ollama).
  nixpkgs.config.nvidia.acceptLicense = true;
}
