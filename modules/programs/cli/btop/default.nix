{
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix) videoDriver;
in
{
  home-manager.sharedModules = [
    (_: {
      programs.btop = {
        enable = true;
        # btop dlopens the GPU vendor library at runtime; the -cuda/-rocm
        # variants add the driver runpath so it can find it.
        package =
          {
            nvidia = pkgs.btop-cuda;
            amdgpu = pkgs.btop-rocm;
          }
          .${videoDriver} or pkgs.btop;
        settings = {
          color_theme = "caelestia";
          show_gpu_info = "On";
          cpu_sensor = "Auto";
          vim_keys = true;
          rounded_corners = true;
          proc_tree = false;
          show_uptime = true;
          show_coretemp = true;
          show_disks = true;
          only_physical = true;
          io_mode = false;
          io_graph_combined = false;
        };
      };
    })
  ];
}
