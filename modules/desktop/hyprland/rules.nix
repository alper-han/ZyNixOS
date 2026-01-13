# Hyprland Window Rules, Layer Rules, and Workspace Rules
# Usage: import ./rules.nix { }
{ }:
let
  # Helper function to generate regex from a list of strings: ^(app1|app2|app3)$
  mkRegex = list: "^(${builtins.concatStringsSep "|" list})$";

  # --- Application Lists ---

  # Browser instances (Opacity 1.0)
  browserApps = [
    "firefox" "Brave-browser" "floorp" "zen" "zen-beta"
  ];

  # High Opacity Apps (0.90 active / 0.80 inactive)
  # Editors, Auth agents, Launchers, Discord
  highOpacityApps = [
    "Emacs" "obsidian" "gcr-prompter" "Hyprland Polkit Agent"
    "Lutris" "lutris" "net.lutris.Lutris"
    "discord" "vesktop" "WebCord"
    "com.github.rafostar.Clapper" # Video player
  ];

  # Medium Opacity Apps (0.80 active / 0.70 inactive)
  # Terminals, IDEs, File Managers, System Tools
  mediumOpacityApps = [
    # Coding
    "VSCodium" "codium-url-handler" "code" "code-url-handler" "nvim-wrapper"
    # Terminals
    "kitty" "alacritty" "Alacritty" "org.wezfurlong.wezterm"
    # File Managers
    "org.gnome.Nautilus" "Thunar" "thunar" "pcmanfm" "thunar-volman-settings"
    "org.kde.dolphin" "tuiFileManager" "org.gnome.FileRoller" "org.kde.ark"
    # System & Tools
    "org.kde.polkit-kde-authentication-agent-1" "gnome-disks" "io.github.ilya_zlobintsev.LACT"
    "Steam" "steam" "steamwebhelper" "hu.kramo.Cartridges"
    "Spotify" "spotify" "Kvantum Manager" "nwg-look" "qt5ct" "qt6ct"
    "Signal" "com.github.tchx84.Flatseal" "com.obsproject.Studio"
    "gnome-boxes" "app.drey.Warp" "net.davidotek.pupgui2"
    "io.gitlab.theevilskeleton.Upscaler" "yad"
    "pavucontrol" "org.pulseaudio.pavucontrol"
    "blueman-manager" ".blueman-manager-wrapped"
    "nm-applet" "nm-connection-editor"
  ];

  # Applications that must always float
  floatingApps = [
    "qt5ct" "nwg-look" "org.kde.ark" "Signal"
    "com.github.rafostar.Clapper" "app.drey.Warp" "net.davidotek.pupgui2"
    "eog" "io.gitlab.theevilskeleton.Upscaler" "yad"
    "pavucontrol" "org.pulseaudio.pavucontrol"
    "blueman-manager" ".blueman-manager-wrapped"
    "nm-applet" "nm-connection-editor"
    "org.kde.polkit-kde-authentication-agent-1"
  ];

  # Applications to center on screen
  centeredApps = [
    "pavucontrol" "blueman-manager" "nm-connection-editor"
  ];

  # Game definitions (Regex for classes)
  gameApps = [
    "steam_app_.*" "gamescope" "Waydroid" "osu!" ".*\\.exe" "pathofexilesteam\\.exe"
  ];

in
{
  # Layer rules (for special surfaces like rofi, notifications)
  layerrule = [
    "blur on, ignore_alpha 0.7, animation fade, match:namespace rofi"
    "no_screen_share on, blur on, ignore_alpha 0, match:namespace swaync-notification-window"
    "blur on, ignore_alpha 0.7, match:namespace swaync-control-center"
  ];

  # Window rules
  windowrule = [
    # === General Rules ===
    "tile on, match:title (.*)(Godot)(.*)$"
    "suppress_event maximize, match:class .*"
    "maximize on, match:class ^(libreoffice.*)$"
    "center on, match:title ^(splash)$"

    # === Opacity Rules (Grouped via Nix) ===
    "opacity 1.00 1.00, match:class ${mkRegex browserApps}"
    "opacity 0.90 0.80, match:class ${mkRegex highOpacityApps}"
    "opacity 0.80 0.70, match:class ${mkRegex mediumOpacityApps}"
    "opacity 0.80 0.70, match:title (.*)(Spotify)(.*)$" # Special title match for Spotify

    # === Floating Rules ===
    "float on, match:class ${mkRegex floatingApps}"
    "center on, match:class ${mkRegex centeredApps}"

    # === Picture-in-Picture (PiP) ===
    "float on, pin on, match:title ^(Picture-in-Picture)$, match:class ${mkRegex browserApps}"
    # Using monitor variables instead of % for precise positioning (Hyprland v0.47+)
    "size 25% 25%, move 73% 4%, match:title ^(Picture-in-Picture)$"

    # === Gaming Rules ===
    "tag +games, match:class ${mkRegex gameApps}"
    "tag +games, match:initial_class ^(.*\\.exe)$"

    # Optimization for games (Combined into single line)
    "immediate on, fullscreen on, border_size 0, no_shadow on, no_blur on, no_anim on, no_initial_focus on, idle_inhibit always, match:tag games"

    # === Specific App Fixes ===
    # Steam: Fix menus and tooltips
    "min_size 1 1, match:class ^(steam)$"

    # Media Players: Prevent screen sleep while focusing
    "idle_inhibit focus, match:class ^(mpv|vlc|celluloid|com.github.rafostar.Clapper)$"
    "idle_inhibit fullscreen, match:class ^(firefox)$"

    # Size Constraints
    "size 800 600, match:class ^(pavucontrol)$"
    "size 600 800, match:class ^(blueman-manager)$"
  ];
}
