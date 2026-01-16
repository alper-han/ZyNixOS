{ lib, ... }:
{
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "schedutil"; # or powersave
        turbo = "never";
      };
    };
  };
}
