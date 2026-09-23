{
  pkgs,
  qtenginePackage,
  darklyPackage,
}:
''
  export QT_QPA_PLATFORMTHEME=qtengine
  # Both Qt generations share Caelestia's qtengine palette and Darkly style.
  export QT_PLUGIN_PATH=${qtenginePackage}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}:${qtenginePackage}/${pkgs.kdePackages.qtbase.qtPluginPrefix}:${darklyPackage}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}:${darklyPackage}/${pkgs.kdePackages.qtbase.qtPluginPrefix}''${QT_PLUGIN_PATH:+:''${QT_PLUGIN_PATH}}
  export CAELESTIA_WALLPAPERS_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers
  export CAELESTIA_SCREENSHOTS_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots
  export CAELESTIA_RECORDINGS_DIR=''${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings
''
