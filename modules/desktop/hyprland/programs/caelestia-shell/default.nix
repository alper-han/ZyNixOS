{
  inputs,
  pkgs,
  host,
  ...
}:

let
  inherit (import ../../../../../hosts/${host}/variables.nix)
    bluetoothSupport
    defaultWallpaper
    fileManager
    isLaptop
    terminal
    ;
  useTwelveHourClock = false;
  wallpapersDir = ../../../../themes/wallpapers;
  defaultWallpaperPath = "${wallpapersDir}/${defaultWallpaper}";

  favouriteApps = [
    "zen-beta"
    "kitty"
    "vesktop"
    "rider"
    "com.github.th_ch.youtube_music"
    "btop"
    "org.kde.kate"
    "github-desktop"
    "mpv"
    "com.obsproject.Studio"
    "steam"
    "rustdesk"
  ];

  hiddenApps = [
    "yad-icon-browser"
    "org.kde.kdeconnect.nonplasma"
    "org.kde.kdeconnect.sms"
    "kvantummanager"
    "rofi"
    "rofi-theme-selector"
    "thunar-settings"
    "yad-settings"
    "org.kde.kwrite"
  ];

  caelestiaSettings = {
    appearance.transparency.enabled = true;

    general = {
      # logo = "caelestia"; # Use "caelestia", an icon name, or an image path for the bar/lock logo.
      apps = {
        terminal = [ terminal ];
        audio = [ "pavucontrol" ];
        playback = [ "mpv" ];
        explorer = [ fileManager ];
      };

      idle = {
        lockBeforeSleep = true;
        inhibitWhenAudio = true;
        timeouts = [
          {
            timeout = 600;
            idleAction = "lock";
          }
          {
            timeout = 360;
            idleAction = "dpms off";
            returnAction = "dpms on";
          }
        ];
      };
    };

    background = {
      enabled = true;
      wallpaperEnabled = true;
      desktopClock = {
        enabled = false;
        position = "bottom-right";
      };
      visualiser = {
        enabled = false;
        autoHide = true;
        blur = false;
      };
    };

    bar = {
      clock = {
        background = true;
        showIcon = true;
        showDate = true;
      };
      dragThreshold = 20;
      persistent = true;
      showOnHover = true;
      status = {
        showAudio = true;
        showBattery = isLaptop;
        showBluetooth = bluetoothSupport;
        showKbLayout = false;
        showLockStatus = false;
        showMicrophone = true;
        showNetwork = true;
        showWifi = false;
      };
      tray = {
        background = true;
        compact = false;
        recolour = false;
      };
      workspaces = {
        perMonitorWorkspaces = true;
        activeIndicator = true;
        activeTrail = true;
        occupiedBg = true;
        showWindows = true;
        shown = 10;
      };
      entries = [
        {
          id = "logo";
          enabled = true;
        }
        {
          id = "workspaces";
          enabled = true;
        }
        {
          id = "spacer";
          enabled = true;
        }
        {
          id = "activeWindow";
          enabled = true;
        }
        {
          id = "spacer";
          enabled = true;
        }
        {
          id = "tray";
          enabled = true;
        }
        {
          id = "clock";
          enabled = true;
        }
        {
          id = "statusIcons";
          enabled = true;
        }
        {
          id = "power";
          enabled = true;
        }
      ];
    };

    border = {
      rounding = 25;
      thickness = 10;
    };

    dashboard = {
      enabled = true;
      dragThreshold = 50;
      mediaUpdateInterval = 500;
      resourceUpdateInterval = 1000;
      showDashboard = true;
      showMedia = true;
      showPerformance = true;
      showWeather = true;
      showOnHover = true;
      performance = {
        showBattery = true;
        showCpu = true;
        showGpu = true;
        showMemory = true;
        showNetwork = true;
        showStorage = true;
      };
    };

    launcher = {
      actionPrefix = ">";
      dragThreshold = 50;
      enabled = true;
      showOnHover = false;
      enableDangerousActions = true;
      vimKeybinds = false;
      maxShown = 9;
      maxWallpapers = 9;
      inherit favouriteApps hiddenApps;
      useFuzzy = {
        apps = true;
        actions = true;
        schemes = true;
        variants = true;
        wallpapers = true;
      };
    };

    notifs = {
      expire = true;
      fullscreen = "on";
      actionOnClick = true;
      clearThreshold = 0.3;
      defaultExpireTimeout = 5000;
      expandThreshold = 20;
      openExpanded = true;
    };

    paths = {
      mediaGif = "root:/assets/bongocat.gif";
      sessionGif = "root:/assets/kurukuru.gif";
      wallpaperDir = "${wallpapersDir}";
    };

    services = {
      audioIncrement = 0.05;
      brightnessIncrement = 0.05;
      maxVolume = 1.25;
      defaultPlayer = "YT Music";
      playerAliases = [
        {
          from = "YoutubeMusic";
          to = "YT Music";
        }
        {
          from = "pear-desktop";
          to = "YT Music";
        }
        {
          from = "com.github.th_ch.youtube_music";
          to = "YT Music";
        }
      ];
      weatherLocation = "Istanbul";
      useFahrenheit = false;
      useFahrenheitPerformance = false;
      smartScheme = true;
      showLyrics = false;
      inherit useTwelveHourClock;
    };

    osd = {
      enabled = true;
      enableBrightness = isLaptop;
      enableMicrophone = true;
      hideDelay = 2000;
    };

    session = {
      dragThreshold = 30;
      enabled = true;
      vimKeybinds = false;
      commands = {
        logout = [
          "loginctl"
          "terminate-user"
        ];
        shutdown = [
          "systemctl"
          "poweroff"
        ];
        hibernate = [
          "systemctl"
          "hibernate"
        ];
        reboot = [
          "systemctl"
          "reboot"
        ];
      };
    };

    lock = {
      enableFprint = false;
      hideNotifs = true;
    };

    sidebar.enabled = true;

    utilities = {
      enabled = true;
      maxToasts = 4;
      toasts = {
        audioInputChanged = true;
        audioOutputChanged = true;
        capsLockChanged = false;
        chargingChanged = true;
        configLoaded = true;
        dndChanged = true;
        gameModeChanged = true;
        kbLayoutChanged = true;
        kbLimit = true;
        numLockChanged = false;
        vpnChanged = false;
        nowPlaying = true;
      };
      quickToggles = [
        {
          id = "wifi";
          enabled = true;
        }
        {
          id = "bluetooth";
          enabled = bluetoothSupport;
        }
        {
          id = "mic";
          enabled = true;
        }
        {
          id = "settings";
          enabled = true;
        }
        {
          id = "gameMode";
          enabled = true;
        }
        {
          id = "dnd";
          enabled = true;
        }
        {
          id = "vpn";
          enabled = false;
        }
      ];
    };
  };

  caelestiaShellJson = pkgs.writeText "caelestia-shell.json" (builtins.toJSON caelestiaSettings);
  caelestiaCliPackage =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
  caelestiaPackage =
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.caelestia-shell.override
      {
        withCli = true;
        caelestia-cli = caelestiaCliPackage;
      };
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        imports = [
          inputs.caelestia-shell.homeManagerModules.default
        ];

        programs.caelestia = {
          enable = true;
          package = caelestiaPackage;
          cli.package = caelestiaCliPackage;
          systemd.enable = false;
          cli = {
            enable = true;
            settings = {
              theme = {
                enableTerm = true;
                enableHypr = true;
                enableDiscord = true;
                enableSpicetify = true;
                enablePandora = true;
                enableFuzzel = true;
                enableBtop = true;
                enableNvtop = true;
                enableHtop = true;
                enableGtk = true;
                enableQt = true;
                enableWarp = true;
                enableChromium = true;
                enableZed = true;
                enableCava = true;
              };
            };
          };
        };

        home.activation.caelestiaWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${config.xdg.configHome}/caelestia"
          mkdir -p "${config.xdg.configHome}/gtk-3.0" "${config.xdg.configHome}/gtk-4.0"

          for gtk_file in \
            "${config.xdg.configHome}/gtk-3.0/gtk.css" \
            "${config.xdg.configHome}/gtk-3.0/thunar.css" \
            "${config.xdg.configHome}/gtk-4.0/gtk.css" \
            "${config.xdg.configHome}/gtk-4.0/thunar.css"; do
            if [ -L "$gtk_file" ]; then
              rm "$gtk_file"
            fi
          done

          if [ -L "${config.xdg.configHome}/caelestia/shell.json" ]; then
            rm "${config.xdg.configHome}/caelestia/shell.json"
          fi

          install -m 0644 "${caelestiaShellJson}" \
            "${config.xdg.configHome}/caelestia/shell.json"

          mkdir -p "${config.xdg.stateHome}/caelestia/wallpaper"
          default_wallpaper="${defaultWallpaperPath}"
          if [ ! -s "${config.xdg.stateHome}/caelestia/wallpaper/path.txt" ]; then
            printf '%s' "$default_wallpaper" > \
              "${config.xdg.stateHome}/caelestia/wallpaper/path.txt"
          fi
          if [ ! -e "${config.xdg.stateHome}/caelestia/wallpaper/current" ]; then
            ln -s "$default_wallpaper" \
              "${config.xdg.stateHome}/caelestia/wallpaper/current"
          fi
        '';
      }
    )
  ];
}
