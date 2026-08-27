{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    editor
    fileManager
    kbdLayout
    kbdVariant
    isLaptop
    defaultWallpaper
    ;

  inherit (lib) getExe getExe';

  wallpapersDir = ../../themes/wallpapers;
  terminalPackage = pkgs.${terminal};
  editorPackage =
    if editor == "kate" || editor == "kwrite" then pkgs.kdePackages.kate else pkgs.${editor};
  wallpaper = "${wallpapersDir}/${defaultWallpaper}";
  fileManagerCommand =
    if fileManager == "thunar" then
      "thunar"
    else if fileManager == "yazi" || fileManager == "lf" then
      "${getExe terminalPackage} -e ${fileManager}"
    else
      fileManager;
in
{
  imports = [ ../../themes/Catppuccin ];

  services.displayManager.defaultSession = "sway";
  services.upower.enable = isLaptop;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  systemd.user.services.xdg-desktop-portal = {
    wants = [ "xdg-desktop-portal-wlr.service" ];
    after = [ "xdg-desktop-portal-wlr.service" ];
  };

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = with pkgs; [
          brightnessctl
          cliphist
          fuzzel
          grim
          hyprpicker
          libnotify
          mako
          pamixer
          pavucontrol
          playerctl
          slurp
          swaybg
          swayidle
          swaylock
          swappy
          waybar
          wf-recorder
          wl-clipboard
          wtype
          xdg-utils
        ];

        xdg.configFile."sway/config".text = ''
          set $mod Mod4
          set $terminal ${getExe terminalPackage}
          set $browser ${browser}
          set $editor ${getExe' editorPackage editor}
          set $fileManager ${fileManagerCommand}
          set $menu ${getExe pkgs.fuzzel}

          set $ws1 1
          set $ws2 2
          set $ws3 3
          set $ws4 4
          set $ws5 5
          set $ws6 6
          set $ws7 7
          set $ws8 8
          set $ws9 9
          set $ws10 10

           exec swaybg -i ${wallpaper} -m fill
           exec waybar
           exec mako
           exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
           exec ${pkgs.runtimeShell} -c '${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME; ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME; ${pkgs.systemd}/bin/systemctl --user start nixos-fake-graphical-session.target'
           exec wl-paste --type text --watch cliphist store
          exec wl-paste --type image --watch cliphist store
          exec rm -f ${config.xdg.cacheHome}/cliphist/db

          set $refresh_i3status killall -SIGUSR1 i3status
          set $clipboard pkill -x fuzzel || ${getExe pkgs.cliphist} list | ${getExe pkgs.fuzzel} --dmenu | ${getExe pkgs.cliphist} decode | ${getExe' pkgs.wl-clipboard "wl-copy"}

          output * bg ${wallpaper} fill

          input * xkb_layout "${kbdLayout}"
          ${lib.optionalString (kbdVariant != "") ''input * xkb_variant "${kbdVariant}"''}
          input * repeat_delay 275
          input * repeat_rate 35
          input type:touchpad tap enabled
          input type:pointer accel_profile flat
          input type:mouse accel_profile flat
          input type:trackpoint accel_profile flat

          gaps inner 3
          default_border pixel 1
          default_floating_border pixel 1
          smart_borders on
          client.focused #ca9ee6 #ca9ee6 #cdd6f4 #ca9ee6 #ca9ee6
          client.focused_inactive #6c7086 #6c7086 #cdd6f4 #6c7086 #6c7086
          client.unfocused #45475a #45475a #bac2de #45475a #45475a
          client.urgent #f38ba8 #f38ba8 #11111b #f38ba8 #f38ba8

          bindsym $mod+Return exec $terminal
          bindsym $mod+t exec $terminal
          bindsym $mod+e exec $fileManager
          bindsym $mod+c exec $editor
          bindsym $mod+f exec $browser
          bindsym $mod+d exec $menu
          bindsym $mod+Space exec $menu
          bindsym $mod+v exec sh -c '$clipboard'

          bindsym $mod+q kill
          bindsym Alt+F4 kill
          bindsym $mod+w floating toggle
          bindsym Alt+Return fullscreen toggle
          bindsym $mod+Shift+e exec swaymsg exit
          bindsym $mod+Alt+l exec swaylock --color 11111b

          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right
          bindsym $mod+h focus left
          bindsym $mod+j focus down
          bindsym $mod+k focus up
          bindsym $mod+l focus right

          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right
          bindsym $mod+Shift+h move left
          bindsym $mod+Shift+j move down
          bindsym $mod+Shift+k move up
          bindsym $mod+Shift+l move right

          bindsym $mod+1 workspace number $ws1
          bindsym $mod+2 workspace number $ws2
          bindsym $mod+3 workspace number $ws3
          bindsym $mod+4 workspace number $ws4
          bindsym $mod+5 workspace number $ws5
          bindsym $mod+6 workspace number $ws6
          bindsym $mod+7 workspace number $ws7
          bindsym $mod+8 workspace number $ws8
          bindsym $mod+9 workspace number $ws9
          bindsym $mod+0 workspace number $ws10

          bindsym $mod+Shift+1 move container to workspace number $ws1
          bindsym $mod+Shift+2 move container to workspace number $ws2
          bindsym $mod+Shift+3 move container to workspace number $ws3
          bindsym $mod+Shift+4 move container to workspace number $ws4
          bindsym $mod+Shift+5 move container to workspace number $ws5
          bindsym $mod+Shift+6 move container to workspace number $ws6
          bindsym $mod+Shift+7 move container to workspace number $ws7
          bindsym $mod+Shift+8 move container to workspace number $ws8
          bindsym $mod+Shift+9 move container to workspace number $ws9
          bindsym $mod+Shift+0 move container to workspace number $ws10

          bindsym $mod+Tab workspace next
          bindsym $mod+Shift+Tab workspace prev
          bindsym $mod+r mode resize
          bindsym $mod+Ctrl+c exec ${getExe pkgs.hyprpicker} --autocopy --format=hex

          bindsym $mod+p exec ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp})" - | ${getExe pkgs.swappy} -f -
          bindsym $mod+Ctrl+p exec ${getExe pkgs.grim} - | ${getExe pkgs.swappy} -f -

          bindsym --locked XF86AudioRaiseVolume exec ${getExe pkgs.pamixer} -i 1
          bindsym --locked XF86AudioLowerVolume exec ${getExe pkgs.pamixer} -d 1
          bindsym --locked XF86AudioMute exec ${getExe pkgs.pamixer} -t
          bindsym --locked XF86AudioMicMute exec ${getExe pkgs.pamixer} --default-source -t
          bindsym --locked XF86AudioPlay exec ${getExe pkgs.playerctl} play-pause
          bindsym --locked XF86AudioPause exec ${getExe pkgs.playerctl} play-pause
          bindsym --locked XF86AudioStop exec ${getExe pkgs.playerctl} stop
          bindsym --locked XF86AudioNext exec ${getExe pkgs.playerctl} next
          bindsym --locked XF86AudioPrev exec ${getExe pkgs.playerctl} previous
          bindsym --locked XF86MonBrightnessDown exec ${getExe pkgs.brightnessctl} set 1%-
          bindsym --locked XF86MonBrightnessUp exec ${getExe pkgs.brightnessctl} set +1%

          mode resize {
              bindsym Left resize shrink width 10px
              bindsym Down resize grow height 10px
              bindsym Up resize shrink height 10px
              bindsym Right resize grow width 10px
              bindsym h resize shrink width 10px
              bindsym j resize grow height 10px
              bindsym k resize shrink height 10px
              bindsym l resize grow width 10px
              bindsym Return mode default
              bindsym Escape mode default
          }

          for_window [app_id="^(pavucontrol|blueman-manager|nm-connection-editor|org\.pulseaudio\.pavucontrol|swappy|hyprpicker)$"] floating enable
          for_window [title="Picture-in-Picture"] floating enable, resize set width 25 ppt height 25 ppt, move position 32 32
        '';
      }
    )
  ];
}
