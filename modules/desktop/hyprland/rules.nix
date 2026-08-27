# Hyprland Window Rules, Layer Rules, and Workspace Rules
# Usage: import ./rules.nix { }
{ }:
let
  mkRegex = list: "^(${builtins.concatStringsSep "|" list})$";

  gameApps = [
    "steam_app_.*"
    "gamescope"
    ".*\\.exe"
    "pathofexilesteam\\.exe"
  ];
in
{
  windowrule = [
    "opacity 0.95 override, match:fullscreen false"
    "suppress_event maximize, match:class .*"
    "opaque on, match:class org\\.quickshell|swappy"
    "center on, match:float 1, match:xwayland 0"

    # Floating
    "float on, match:class yad"
    "float on, match:class org\\.gnome\\.FileRoller"
    "float on, match:class file-roller"
    "float on, match:class peazip"
    "float on, match:class PeaZip"
    "float on, match:class blueman-manager"
    "float on, match:class org\\.quickshell"
    "center on, match:title ^(Open File)(.*)$"
    "float on, match:title ^(Open File)(.*)$"
    "center on, match:title ^(Select a File)(.*)$"
    "float on, match:title ^(Select a File)(.*)$"
    "center on, match:title ^(Choose wallpaper)(.*)$"
    "float on, match:title ^(Choose wallpaper)(.*)$"
    "size 60% 65%, match:title ^(Choose wallpaper)(.*)$"
    "center on, match:title ^(Open Folder)(.*)$"
    "float on, match:title ^(Open Folder)(.*)$"
    "center on, match:title ^(Save As)(.*)$"
    "float on, match:title ^(Save As)(.*)$"
    "center on, match:title ^(Library)(.*)$"
    "float on, match:title ^(Library)(.*)$"
    "center on, match:title ^(File Upload)(.*)$"
    "float on, match:title ^(File Upload)(.*)$"
    "center on, match:title ^(.*)(wants to save)$"
    "float on, match:title ^(.*)(wants to save)$"
    "center on, match:title ^(.*)(wants to open)$"
    "float on, match:title ^(.*)(wants to open)$"
    "float on, center on, match:class ^(thunar)$, match:title ^(File Operation Progress)$"
    "size 500 100, match:class ^(thunar)$, match:title ^(File Operation Progress)$"
    "float on, match:class ^(pavucontrol)$"
    "size 60% 70%, match:class ^(pavucontrol)$"
    "center on, match:class ^(pavucontrol)$"
    "float on, match:class ^(org\\.pulseaudio\\.pavucontrol|yad-icon-browser)$"
    "size 60% 70%, match:class ^(org\\.pulseaudio\\.pavucontrol|yad-icon-browser)$"
    "center on, match:class ^(org\\.pulseaudio\\.pavucontrol|yad-icon-browser)$"
    "float on, match:class ^(nm-connection-editor)$"
    "size 45% 45%, match:class ^(nm-connection-editor)$"
    "center on, match:class ^(nm-connection-editor)$"
    "float on, match:title .*Welcome"
    # "no_blur on, match:class ^(Xdg-desktop-portal-gtk)$"
    "border_size 0, match:class ^(Xdg-desktop-portal-gtk)$"

    # Special workspaces
#    "workspace special:sysmon, match:class btop"
#    "workspace special:music, match:class Spotify|com.github.th_ch.youtube_music"
#    "workspace special:music, match:initial_title Spotify( Free)?"
#    "workspace special:communication, match:class discord|vesktop"
#    "workspace special:rider, match:class rider|jetbrains-rider"
#    "workspace special:jellyfin, match:class jellyfin-desktop|Jellyfin Media Player|com.github.iwalton3.jellyfin-media-player"
#    "workspace special:virt-manager, match:class virt-manager|org.virt-manager.virt-manager"
#    "workspace special:rustdesk, match:class rustdesk|RustDesk"
#    "workspace special:pear, match:class pear-desktop"
#    "workspace special:obs, match:class com.obsproject.Studio|obs"
#    "workspace special:steam, match:class steam"

    # Dialogs
    "float on, match:title (Select|Open)( a)? (File|Folder)(s)?"
    "float on, match:title File (Operation|Upload)( Progress)?"
    "float on, match:title .* Properties"
    "float on, match:title Export Image as PNG"
    "float on, match:title GIMP Crash Debug"

    # Picture-in-Picture
    "move 100%-w-2% 100%-w-3%, match:title Picture(-| )in(-| )[Pp]icture"
    "keep_aspect_ratio on, match:title Picture(-| )in(-| )[Pp]icture"
    "float on, match:title Picture(-| )in(-| )[Pp]icture"
    "pin on, match:title Picture(-| )in(-| )[Pp]icture"

    # Steam
    "rounding 10, match:class steam"
    "float on, match:title Friends List, match:class steam"

    # Screen sharing
    "float on, match:title .*is sharing (a window|your screen).*"
    "pin on, match:title .*is sharing (a window|your screen).*"
    "move 50% 100%-12, match:title .*is sharing (a window|your screen).*"

    # Idle inhibit
    "idle_inhibit focus, match:class ^(mpv)$"
    "idle_inhibit focus, match:class ^(jellyfin-desktop|Jellyfin Media Player|com.github.iwalton3.jellyfin-media-player)$"
    "idle_inhibit focus, match:class ^(com.github.th_ch.youtube_music)$"
    "idle_inhibit fullscreen, match:class ^([Zz]en(-beta|-browser)?)$"

    # XWayland popups
    "no_dim on, match:xwayland 1, match:title win[0-9]+"
    "no_shadow on, match:xwayland 1, match:title win[0-9]+"
    "rounding 10, match:xwayland 1, match:title win[0-9]+"

    # Gaming rules
    "opaque on, match:class (steam_app_(default|[0-9]+))|gamescope"
    "immediate on, match:class (steam_app_(default|[0-9]+))|gamescope"
    "idle_inhibit always, match:class (steam_app_(default|[0-9]+))|gamescope"
    "tag +games, match:class ${mkRegex gameApps}"
    "tag +games, match:initial_class ^(.*\\.exe)$"
    "immediate on, fullscreen on, border_size 0, no_anim on, no_initial_focus on, idle_inhibit always, match:tag games"
  ];

  layerrule = [
    "no_anim on, match:namespace walker"
    "no_anim on, match:namespace overview"
    "no_anim on, match:namespace anyrun"
    "no_anim on, match:namespace indicator.*"
    "no_anim on, match:namespace osk"
    "no_anim on, match:namespace noanim"
    "animation fade, match:namespace hyprpicker"
    "animation fade, match:namespace logout_dialog"
    "animation fade, match:namespace selection"
    "animation fade, match:namespace wayfreeze"
    "animation popin 80%, match:namespace launcher"
    "blur on, match:namespace launcher"
    "no_anim on, match:namespace caelestia-(border-exclusion|area-picker)"
    "animation fade, match:namespace caelestia-(drawers|background)"

    # Quickshell: illogical-impulse
    "animation slide, match:namespace quickshell:bar"
    "no_anim on, match:namespace quickshell:actionCenter"
    "animation slide bottom, match:namespace quickshell:cheatsheet"
    "animation slide bottom, match:namespace quickshell:dock"
    "animation popin 120%, match:namespace quickshell:screenCorners"
    "no_anim on, match:namespace quickshell:lockWindowPusher"
    "animation fade, match:namespace quickshell:notificationPopup"
    "no_anim on, match:namespace quickshell:overlay"
    "ignore_alpha 1, match:namespace quickshell:overlay"
    "no_anim on, match:namespace quickshell:overview"
    "animation slide bottom, match:namespace quickshell:osk"
    "no_anim on, match:namespace quickshell:polkit"
    "animation slide, match:namespace quickshell:reloadPopup"
    "no_anim on, match:namespace quickshell:regionSelector"
    "no_anim on, match:namespace quickshell:screenshot"
    "no_anim on, match:namespace quickshell:session"
    "animation slide right, match:namespace quickshell:sidebarRight"
    "animation slide left, match:namespace quickshell:sidebarLeft"
    "animation slide, match:namespace quickshell:verticalBar"
    "order -1, match:namespace quickshell:osk"

    # Launchers need to be FAST
    "no_anim on, match:namespace gtk4-layer-shell"
  ];
}
