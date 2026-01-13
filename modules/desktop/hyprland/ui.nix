# Hyprland Visual Settings: Appearance, Decorations, Animations
# Usage: import ./ui.nix { }
{ }:
{
  # General appearance
  general = {
    gaps_in = 1;
    gaps_out = 0;
    border_size = 1;
    "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    resize_on_border = true;
    layout = "dwindle"; # dwindle or master
    allow_tearing = true; # Allow tearing for games (use immediate window rules for specific games or all titles)
  };

  # Decoration (shadows, blur, rounding)
  decoration = {
    shadow.enabled = false;
    rounding = 0;
    dim_special = 0.3;
    blur = {
      enabled = true;
      special = true;
      size = 6; # 6
      passes = 2; # 3
      vibrancy = 0.1696;
      popups = false;
      new_optimizations = true;
      ignore_opacity = true;
      xray = false;
    };
  };

  # Window grouping colors
  group = {
    "col.border_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    "col.border_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
  };

  # Animations
  animations = {
    enabled = true;
    bezier = [
      "linear, 0, 0, 1, 1"
      "md3_standard, 0.2, 0, 0, 1"
      "md3_decel, 0.05, 0.7, 0.1, 1"
      "md3_accel, 0.3, 0, 0.8, 0.15"
      "overshot, 0.05, 0.9, 0.1, 1.1"
      "crazyshot, 0.1, 1.5, 0.76, 0.92"
      "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
      "fluent_decel, 0.1, 1, 0, 1"
      "easeInOutCirc, 0.85, 0, 0.15, 1"
      "easeOutCirc, 0, 0.55, 0.45, 1"
      "easeOutExpo, 0.16, 1, 0.3, 1"
      "zoomEase, 0.16, 1, 0.3, 1"  # Special bezier for Zoom
    ];
    animation = [
      "windows, 1, 3, md3_decel, popin 60%"
      "border, 1, 4, default"
      "fade, 1, 2.5, md3_decel"
      # "workspaces, 1, 3.5, md3_decel, slide"
      "workspaces, 1, 3.5, easeOutExpo, slide"
      # "workspaces, 1, 7, fluent_decel, slidefade 15%"
      # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
      "specialWorkspace, 1, 3, md3_decel, slidevert"
      "zoomFactor, 1, 6, zoomEase"  # Zoom animation - 600ms
    ];
  };
}
