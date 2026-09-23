{ lib, pkgs, ... }:
{
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;

    settings = {
      rule_load = true;
      type_load = true;

      # Compatible with sched_ext; disable Ananicy if scheduling stalls occur.
      apply_nice = true;
      apply_sched = true;
      apply_ionice = true;
      apply_ioclass = true;
      apply_oom_score_adj = true;
      apply_cpuset = true;

      # Periodic fallback scan; process events remain primary.
      check_freq = 15;

      # CachyOS cgroup and CPUQuota rules.
      apply_cgroup = true;
      cgroup_load = true;

      # Avoid boot-time EINVAL when moving realtime tasks to the root cgroup.
      cgroup_realtime_workaround = lib.mkForce false;

      # latency_nice requires kernel support and is not used by the installed
      # CachyOS ruleset. Leave it off until both are deliberately verified.
      apply_latnice = false;

      # Enable rule logging only for diagnostics.
      loglevel = "warn";
      log_applied_rule = false;

      # Do not change AMD X3D driver policy implicitly.
      x3d_mode = "auto";
    };
  };

  # Let Ananicy manage its delegated cgroup subtree.
  systemd.services.ananicy-cpp.serviceConfig.Delegate = true;
}
