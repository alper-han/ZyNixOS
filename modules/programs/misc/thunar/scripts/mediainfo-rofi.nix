{ pkgs, ... }:
pkgs.writeShellScriptBin "mediainfo-rofi" ''
  # Thunar Media Info with Rofi

  FILE="$1"
  rofi_theme="$HOME/.config/rofi/launchers/type-1/style-6.rasi"

  if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    ${pkgs.libnotify}/bin/notify-send "Media Info Error" "No valid file selected" -i dialog-error
    exit 1
  fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")

  # Get media info
  INFO=$(${pkgs.mediainfo}/bin/mediainfo "$FILE" 2>/dev/null)

  if [[ -z "$INFO" ]]; then
    ${pkgs.libnotify}/bin/notify-send "Media Info" "Could not read media information" -i dialog-warning
    exit 1
  fi

  # Parse key info
  FORMAT=$(${pkgs.mediainfo}/bin/mediainfo --Inform="General;%Format%" "$FILE")
  DURATION=$(${pkgs.mediainfo}/bin/mediainfo --Inform="General;%Duration/String3%" "$FILE")
  FILESIZE=$(${pkgs.mediainfo}/bin/mediainfo --Inform="General;%FileSize/String%" "$FILE")
  BITRATE=$(${pkgs.mediainfo}/bin/mediainfo --Inform="General;%OverallBitRate/String%" "$FILE")

  # Video info
  V_CODEC=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Video;%Format%" "$FILE")
  V_RES=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Video;%Width%x%Height%" "$FILE")
  V_FPS=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Video;%FrameRate% fps" "$FILE")
  V_BITRATE=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Video;%BitRate/String%" "$FILE")

  # Audio info
  A_CODEC=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Audio;%Format%" "$FILE")
  A_CHANNELS=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Audio;%Channel(s)% ch" "$FILE")
  A_SAMPLERATE=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Audio;%SamplingRate/String%" "$FILE")
  A_BITRATE=$(${pkgs.mediainfo}/bin/mediainfo --Inform="Audio;%BitRate/String%" "$FILE")

  # Build all text for copy
  ALL_TEXT="File: $FILENAME
Format: $FORMAT
Duration: $DURATION
File Size: $FILESIZE
Bitrate: $BITRATE
---
Video Codec: $V_CODEC
Resolution: $V_RES
Frame Rate: $V_FPS
Video Bitrate: $V_BITRATE
---
Audio Codec: $A_CODEC
Channels: $A_CHANNELS
Sample Rate: $A_SAMPLERATE
Audio Bitrate: $A_BITRATE"

  # Build menu with icons
  MENU="󰆏 Copy All Info	copy_all
━━━━━━━━━━━━━━━
 Format	$FORMAT
 Duration	$DURATION
 File Size	$FILESIZE
 Bitrate	$BITRATE
━━━━━━━━━━━━━━━
 Video Codec	$V_CODEC
 Resolution	$V_RES
 Frame Rate	$V_FPS
 Video Bitrate	$V_BITRATE
━━━━━━━━━━━━━━━
 Audio Codec	$A_CODEC
 Channels	$A_CHANNELS
 Sample Rate	$A_SAMPLERATE
 Audio Bitrate	$A_BITRATE"

  # Show in rofi with theme
  SELECTED=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " Media Info" \
    -mesg "🎬 $FILENAME" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 16;}' \
    -theme-str 'window {width: 600px;}' \
    -no-custom)

  if [[ -n "$SELECTED" ]]; then
    ACTION=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $2}')
    if [[ "$ACTION" == "copy_all" ]]; then
      echo -n "$ALL_TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send "󰆏 All Info Copied" "Media information copied to clipboard" -i edit-copy
    else
      VALUE="$ACTION"
      LABEL=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $1}' | ${pkgs.gnused}/bin/sed 's/^[^ ]* //')
      echo -n "$VALUE" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send " $LABEL Copied" "Value copied to clipboard" -i edit-copy
    fi
  fi
''
