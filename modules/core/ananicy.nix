{ pkgs, ... }:
{
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      # Avoid noisy boot-time cgroup EINVAL errors while keeping priority tuning active.
      apply_cgroup = false;
      cgroup_load = false;
    };
  };
}
