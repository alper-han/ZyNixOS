{ pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = [
    # lutris
    # heroic
    # bottles
    # ryujinx
    # prismlauncher

    # steam-run
    # wineWow64Packages.staging
    # gamescope
    # protonup-qt # Used to manually download CachyOS Proton v4
    # protonplus
  ];
  programs = {
    gamemode.enable = lib.mkForce false;
    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession = {
        enable = true;
        args = [
          "--rt"
          "--expose-wayland"
          "--immediate-flips"  # Tearing and low input lag
          # "--adaptive-sync"  # G-Sync/FreeSync
        ];
      };
    };
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"

        # experimental
        "--immediate-flips"
      ];
      package = pkgs.gamescope;
    };
  };
  home-manager.sharedModules = [
  (_: {
    programs.mangohud = {
      enable = true;
      enableSessionWide = false;
      settingsPerApplication = {
        mpv = {
          no_display = true;
        };
      };
      settings = {
        no_display = true;
        fps_limit = [0 144 60];
        fps_limit_method = "early";
        vsync = 1;
        gl_vsync = 0;
        horizontal = false;
        horizontal_separator_color = "00FFFF";
        horizontal_stretch = true;

        # Keybinds
        toggle_hud = "Shift_R+F12";
        toggle_hud_position = "Shift_R+F11";
        toggle_fps_limit = "Shift_R+F1";

        # Use legacy layout for better control over display order
        legacy_layout = true;

        # Display order (top to bottom)
        # CPU section
        cpu_stats = true;
        cpu_temp = true;
        cpu_power = true;
        cpu_mhz = true;
        cpu_text = "CPU";

        # GPU section
        gpu_stats = true;
        gpu_temp = true;
        gpu_core_clock = true;
        gpu_mem_clock = true;
        gpu_power = true;
        gpu_text = "GPU";
        vram = true;
        proc_vram = true;
        throttling_status = true;

        # FPS and performance metrics
        fps = true;
        show_fps_limit = true;
        frametime = true;
        resolution = true;
        present_mode = true;

        # System information
        ram = true;
        gamemode = false;
        display_server = true;
        engine_version = true;
        dx_api = true;
        wine = true;
        winesync = true;
        network = true;
      };
    };
  })
];
}
