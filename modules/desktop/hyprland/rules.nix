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
  # Editors, Auth agents, Launchers, Discord, Media Apps
  highOpacityApps = [
    "Emacs" "obsidian" "gcr-prompter" "Hyprland Polkit Agent"
    "Lutris" "lutris" "net.lutris.Lutris"
    "discord" "vesktop" "WebCord"
    "com.github.rafostar.Clapper"
    # Video Editing / Media Production
    "resolve" # DaVinci Resolve class name
    "YouTube Music" "youtube-music"
    # IDEs (JetBrains - also matches -ce variants via regex)
    "jetbrains-rider" "jetbrains-idea" "jetbrains-idea-ce"
    "jetbrains-webstorm" "jetbrains-clion" "jetbrains-pycharm" "jetbrains-pycharm-ce"
    "jetbrains-goland" "jetbrains-datagrip" "jetbrains-phpstorm" "jetbrains-rubymine"
    # GitHub Desktop
    "GitHub Desktop" "github-desktop"
    # Text Editors
    "org.gnome.gedit" "gedit" "org.gnome.TextEditor"
    "org.kde.kate" "kate" "org.kde.kwrite" "kwrite"
    # Remote Desktop
    "rustdesk" "RustDesk"
    # Media
    "jellyfin" "Jellyfin Media Player"
  ];

  # Medium Opacity Apps (0.80 active / 0.70 inactive)
  # Terminals, File Managers, System Tools
  mediumOpacityApps = [
    # Coding
    "VSCodium" "codium-url-handler" "code" "code-url-handler" "nvim-wrapper"
    # Terminals
    "kitty" "alacritty" "Alacritty" "org.wezfurlong.wezterm"
    # File Managers
    "org.gnome.Nautilus" "Thunar" "thunar" "pcmanfm" "thunar-volman-settings"
    "org.kde.dolphin" "tuiFileManager" "org.gnome.FileRoller" "org.kde.ark"
    "peazip" "PeaZip"
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
    # Container / Virtualization
    "io.podman_desktop.PodmanDesktop" "podman-desktop"
    # Database
    "sqlitebrowser" "DB Browser for SQLite"
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
    "peazip" "PeaZip"
    # Remote Desktop
    "rustdesk" "RustDesk"
    # Audio
    "com.github.wwmm.easyeffects" "easyeffects"
    # Screenshot / Color Picker
    "swappy" "org.gnome.Screenshot" "hyprpicker"
    # KDE Connect
    "org.kde.kdeconnect.app" "kdeconnect-app" "kdeconnect-indicator" "kdeconnect-settings"
    # Backup
    "Duplicati" "duplicati"
    # Virtualization
    "virt-viewer" "remote-viewer" "virt-manager"
    # Settings
    "gnome-tweaks" "org.gnome.tweaks"
    # Database
    "sqlitebrowser" "DB Browser for SQLite"
  ];

  # Applications to center on screen
  centeredApps = [
    "pavucontrol" "blueman-manager" "nm-connection-editor"
    # New additions
    "rustdesk" "RustDesk"
    "easyeffects" "com.github.wwmm.easyeffects"
    "swappy" "hyprpicker"
    "sqlitebrowser"
    "virt-viewer" "virt-manager"
    "gnome-tweaks"
    "Duplicati"
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
    "float on, center on, match:title ^(Steam)$, match:class ^()$"

    # === Idle Inhibit (Prevent sleep while media playing) ===
    "idle_inhibit focus, match:class ^(mpv|vlc|celluloid|com.github.rafostar.Clapper)$"
    "idle_inhibit focus, match:class ^(jellyfin|resolve|DaVinci Resolve)$"
    "idle_inhibit focus, match:title ^(YouTube Music)$"
    "idle_inhibit fullscreen, match:class ^(firefox)$"

    # === DaVinci Resolve Special Windows (Float) ===
    # Project Manager and loader should float, not maximize
    "float on, center on, match:class ^(resolve)$, match:title ^(resolve)$"
    "float on, center on, match:class ^(resolve)$, match:title ^(Project Manager)$"
    "float on, center on, match:class ^(resolve)$, match:title ^(Preferences)$"
    "float on, center on, match:class ^(resolve)$, match:title ^(Quick Export)$"

    # === Size Constraints ===
    "size 1000 700, match:class ^(pavucontrol|org.pulseaudio.pavucontrol)$"
    "size 600 800, match:class ^(blueman-manager)$"
    "size 1200 800, match:class ^(rustdesk|RustDesk)$"
    "size 900 650, match:class ^(easyeffects|com.github.wwmm.easyeffects)$"
    "size 800 600, match:class ^(swappy)$"
    "size 400 300, match:class ^(hyprpicker)$"
    "size 1100 700, match:class ^(sqlitebrowser|DB Browser for SQLite)$"
    "size 1000 700, match:class ^(virt-manager)$"
    "size 900 600, match:class ^(virt-viewer|remote-viewer)$"
    "size 800 600, match:class ^(gnome-tweaks|org.gnome.tweaks)$"
    "size 1000 700, match:class ^(Duplicati|duplicati)$"
  ];
}
