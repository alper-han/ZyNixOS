{ lib, ... }:
{
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      # Intel laptops run intel_pstate in active mode, which only offers the performance
      # and powersave governors; efficiency is steered through EPP instead.
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "balance_power";
        turbo = "never";
      };
    };
  };
}
