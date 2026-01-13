{ pkgs, lib, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      let
        ytMusicConfig = {
          window-maximized = true;
          url = "https://music.youtube.com";
          options = {
            tray = true;
            appVisible = true;
            autoUpdates = false;
            alwaysOnTop = false;
            hideMenu = true;
            hideMenuWarned = true;
            startAtLogin = false;
            disableHardwareAcceleration = false;
            removeUpgradeButton = true;
            restartOnConfigChanges = false;
            trayClickPlayPause = false;
            autoResetAppCache = false;
            resumeOnStart = false;
            likeButtons = "force";
            proxy = "";
            startingPage = "";
            overrideUserAgent = false;
            usePodcastParticipantAsArtist = false;
            themes = [
              "${config.home.homeDirectory}/.config/YouTube Music/themes/catppuccin-mocha.css"
            ];
          };
          plugins = {
            notifications.enabled = false;
            skip-disliked-songs.enabled = false;
            performance-improvement.enabled = true;
            navigation.enabled = false;
            unobtrusive-player.enabled = false;
            in-app-menu.enabled = false;
            scrobbler.enabled = false;
            video-toggle = {
              enabled = true;
              mode = "custom";
              hideVideo = true;
              forceHide = false;
              align = "left";
            };
            shortcuts.enabled = true;
            precise-volume = {
              globalShortcuts = { };
            };
            discord.listenAlong = true;
            bypass-age-restrictions.enabled = true;
            sponsorblock.enabled = true;
            downloader.enabled = true;
            audio-compressor.enabled = false;
            blur-nav-bar.enabled = false;
            equalizer.enabled = false;
            ambient-mode.enabled = false;
            amuse.enabled = false;
            quality-changer.enabled = true;
            music-together.enabled = true;
            visualizer = {
              enabled = false;
              type = "vudio";
              butterchurn = {
                preset = "martin [shadow harlequins shape code] - fata morgana";
                renderingFrequencyInMs = 500;
                blendTimeInSeconds = 2.7;
              };
              vudio = {
                effect = "lighting";
                accuracy = 128;
                lighting = {
                  maxHeight = 160;
                  maxSize = 12;
                  lineWidth = 1;
                  color = "#49f3f7";
                  shadowBlur = 2;
                  shadowColor = "rgba(244,244,244,.5)";
                  fadeSide = true;
                  prettify = false;
                  horizontalAlign = "center";
                  verticalAlign = "middle";
                  dottify = true;
                };
              };
              wave = {
                animations = [
                  {
                    type = "Cubes";
                    config = {
                      bottom = true;
                      count = 30;
                      cubeHeight = 5;
                      fillColor = {
                        gradient = [
                          "#FAD961"
                          "#F76B1C"
                        ];
                      };
                      lineColor = "rgba(0,0,0,0)";
                      radius = 20;
                    };
                  }
                  {
                    type = "Cubes";
                    config = {
                      top = true;
                      count = 12;
                      cubeHeight = 5;
                      fillColor = {
                        gradient = [
                          "#FAD961"
                          "#F76B1C"
                        ];
                      };
                      lineColor = "rgba(0,0,0,0)";
                      radius = 10;
                    };
                  }
                  {
                    type = "Circles";
                    config = {
                      lineColor = {
                        gradient = [
                          "#FAD961"
                          "#FAD961"
                          "#F76B1C"
                        ];
                        rotate = 90;
                      };
                      lineWidth = 4;
                      diameter = 20;
                      count = 10;
                      frequencyBand = "base";
                    };
                  }
                ];
              };
            };
          };
        };
      in
      {
        home.packages = with pkgs; [
          pear-desktop
          curl
          jq
        ];

        home.activation.setupYoutubeMusic = lib.mkAfter ''
          THEME_DIR="$HOME/.config/YouTube Music/themes"
          THEME_FILE="$THEME_DIR/catppuccin-mocha.css"
          if ! [ -f "$THEME_FILE" ]; then
            echo "YouTube Music theme not found. Downloading..."
            export PATH=${pkgs.curl}/bin:$PATH
            mkdir -p "$THEME_DIR"
            curl -sSfL "https://raw.githubusercontent.com/catppuccin/youtubemusic/main/src/macchiato.css" -o "$THEME_FILE"
          fi

          CONFIG_DIR="$HOME/.config/YouTube Music"
          CONFIG_FILE="$CONFIG_DIR/config.json"
          
          if ! [ -f "$CONFIG_FILE" ]; then
            echo "YouTube Music config.json not found. Creating initial config..."
            mkdir -p "$CONFIG_DIR"
            echo '${builtins.toJSON ytMusicConfig}' > "$CONFIG_FILE"
          fi
        '';
      }
    )
  ];
}
