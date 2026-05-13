{ pkgs }:
''
  export QT_QPA_PLATFORMTHEME=qtengine
  export QT_PLUGIN_PATH=${pkgs.qtengine}/lib/qt-6/plugins''${QT_PLUGIN_PATH:+:''${QT_PLUGIN_PATH}}
  export CAELESTIA_WALLPAPERS_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers
  export CAELESTIA_SCREENSHOTS_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots
  export CAELESTIA_RECORDINGS_DIR=''${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings
''
