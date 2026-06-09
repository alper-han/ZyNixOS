# Hyprland Visual Settings: Appearance, Decorations, Animations
# Usage: import ./ui.nix { inherit bar; }
{ bar }:
{
  # General appearance
  general = {
    gaps_workspaces = 20;
    gaps_in = 5;
    gaps_out = 10;
    border_size = 1;
    "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    resize_on_border = false;
    layout = "dwindle"; # dwindle or master
    allow_tearing = true; # Allow tearing for games (use immediate window rules for specific games or all titles)
  };

  # Decoration (shadows, blur, rounding)
  decoration = {
    shadow = {
      enabled = true;
      range = 15;
      render_power = 4;
      color = "rgba(59599210)";
    };
    rounding = if bar == "caelestia-shell" then 15 else 0;
    dim_special = 0.3;
    blur = {
      enabled = true;
      xray = false;
      special = false;
      ignore_opacity = true;
      new_optimizations = true;
      popups = true;
      input_methods = true;
      size = 8;
      passes = 2;
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
    # end-4/dots-hyprland inspired Material-style animations.
    bezier = [
      "expressiveFastSpatial, 0.42, 1.67, 0.21, 0.90"
      "expressiveSlowSpatial, 0.39, 1.29, 0.35, 0.98"
      "expressiveDefaultSpatial, 0.38, 1.21, 0.22, 1.00"
      "emphasizedDecel, 0.05, 0.7, 0.1, 1"
      "emphasizedAccel, 0.3, 0, 0.8, 0.15"
      "standardDecel, 0, 0, 0, 1"
      "menu_decel, 0.1, 1, 0, 1"
      "menu_accel, 0.52, 0.03, 0.72, 0.08"
      "stall, 1, -0.1, 0.7, 0.85"
    ];
    animation = [
      "windowsIn, 1, 3, emphasizedDecel, popin 80%"
      "fadeIn, 1, 3, emphasizedDecel"
      "windowsOut, 1, 2, emphasizedDecel, popin 90%"
      "fadeOut, 1, 2, emphasizedDecel"
      "windowsMove, 1, 3, emphasizedDecel, slide"
      "border, 1, 10, emphasizedDecel"
      "layersIn, 1, 2.7, emphasizedDecel, popin 93%"
      "layersOut, 1, 2.4, menu_accel, popin 94%"
      "fadeLayersIn, 1, 0.5, menu_decel"
      "fadeLayersOut, 1, 2.7, stall"
      "workspaces, 1, 7, menu_decel, slide"
      "specialWorkspaceIn, 1, 2.8, emphasizedDecel, slidevert"
      "specialWorkspaceOut, 1, 1.2, emphasizedAccel, slidevert"
      "zoomFactor, 1, 3, standardDecel"
    ];
  };
}
