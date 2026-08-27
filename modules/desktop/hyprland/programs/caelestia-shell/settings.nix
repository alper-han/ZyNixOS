{
  bluetoothSupport,
  fileManager,
  isLaptop,
  terminal,
}:
let
  useTwelveHourClock = false;

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
in
{
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
          timeout = 300;
          idleAction = "lock";
        }
        # {
        #   timeout = 600;
        #   idleAction = "dpms off";
        #   returnAction = "dpms on";
        # }
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
    statusIcons = [
      {
        id = "lockStatus";
        enabled = false;
      }
      {
        id = "audio";
        enabled = true;
      }
      {
        id = "microphone";
        enabled = true;
      }
      {
        id = "kbLayout";
        enabled = false;
      }
      {
        id = "network";
        enabled = true;
      }
      {
        id = "bluetooth";
        enabled = bluetoothSupport;
      }
      {
        id = "battery";
        enabled = isLaptop;
      }
    ];
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
  };

  services = {
    audioIncrement = 0.05;
    brightnessIncrement = 0.05;
    maxVolume = 1.0;
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
        ""
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
      # position = "top-right";
      audioInputChanged = false;
      audioOutputChanged = false;
      capsLockChanged = false;
      chargingChanged = false;
      configLoaded = false;
      dndChanged = false;
      gameModeChanged = false;
      kbLayoutChanged = false;
      kbLimit = false;
      numLockChanged = false;
      vpnChanged = false;
      nowPlaying = false;
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
}
