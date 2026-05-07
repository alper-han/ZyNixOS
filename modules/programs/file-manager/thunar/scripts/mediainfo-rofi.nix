{ pkgs, rofiTheme, ... }:
pkgs.writeShellScriptBin "mediainfo-rofi" ''
    # Thunar Media Info with Rofi

    FILE="$1"
    rofi_theme="${rofiTheme}"

    if [[ -z "$FILE" || ! -f "$FILE" ]]; then
      ${pkgs.libnotify}/bin/notify-send "Media Info Error" "No valid file selected" -i dialog-error
      exit 1
    fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")

  one_line() {
    ${pkgs.coreutils}/bin/printf '%s' "$1" | ${pkgs.coreutils}/bin/tr '\t\n' '  ' | ${pkgs.gnused}/bin/sed 's/[[:space:]]\+/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//'
  }

    copy_text() {
      local text="$1"
      local title="$2"
      local message="$3"

      if ${pkgs.coreutils}/bin/printf '%s' "$text" | ${pkgs.wl-clipboard}/bin/wl-copy --type text/plain; then
        ${pkgs.libnotify}/bin/notify-send "$title" "$message" -i edit-copy
      else
        ${pkgs.libnotify}/bin/notify-send "Clipboard Error" "Failed to copy to clipboard" -i dialog-error
        return 1
      fi
    }

    media_field() {
      local value
    value=$(${pkgs.mediainfo}/bin/mediainfo --Inform="$1" "$FILE" 2>/dev/null)
    if [[ -n "$value" ]]; then
      one_line "$value"
    else
      return 1
    fi
  }

  or_na() {
    if [[ -n "$1" ]]; then
      ${pkgs.coreutils}/bin/printf '%s' "$1"
    else
      ${pkgs.coreutils}/bin/printf 'N/A'
    fi
  }

    # Get media info
    INFO=$(${pkgs.mediainfo}/bin/mediainfo "$FILE" 2>/dev/null)

    if [[ -z "$INFO" ]]; then
      ${pkgs.libnotify}/bin/notify-send "Media Info" "Could not read media information" -i dialog-warning
      exit 1
    fi

    # Parse key info
  FORMAT=$(or_na "$(media_field 'General;%Format%')")
  DURATION=$(or_na "$(media_field 'General;%Duration/String3%')")
  FILESIZE=$(or_na "$(media_field 'General;%FileSize/String%')")
  BITRATE=$(or_na "$(media_field 'General;%OverallBitRate/String%')")

  # Video info
  V_CODEC=$(or_na "$(media_field 'Video;%Format%')")
  V_WIDTH=$(media_field 'Video;%Width%')
  V_HEIGHT=$(media_field 'Video;%Height%')
  if [[ -n "$V_WIDTH" && -n "$V_HEIGHT" ]]; then
    V_RES="''${V_WIDTH}x''${V_HEIGHT}"
  else
    V_RES="N/A"
  fi
  V_FRAMERATE=$(media_field 'Video;%FrameRate%')
  if [[ -n "$V_FRAMERATE" ]]; then
    V_FPS="$V_FRAMERATE fps"
  else
    V_FPS="N/A"
  fi
  V_BITRATE=$(or_na "$(media_field 'Video;%BitRate/String%')")

  # Audio info
  A_CODEC=$(or_na "$(media_field 'Audio;%Format%')")
  A_CHANNEL_COUNT=$(media_field 'Audio;%Channel(s)%')
  if [[ -n "$A_CHANNEL_COUNT" ]]; then
    A_CHANNELS="$A_CHANNEL_COUNT ch"
  else
    A_CHANNELS="N/A"
  fi
  A_SAMPLERATE=$(or_na "$(media_field 'Audio;%SamplingRate/String%')")
  A_BITRATE=$(or_na "$(media_field 'Audio;%BitRate/String%')")

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

  labels=(
    "󰆏 Copy All Info"
    "━━━━━━━━━━━━━━━"
    " Format         $FORMAT"
    " Duration       $DURATION"
    " File Size      $FILESIZE"
    " Bitrate        $BITRATE"
    "━━━━━━━━━━━━━━━"
    " Video Codec    $V_CODEC"
    " Resolution     $V_RES"
    " Frame Rate     $V_FPS"
    " Video Bitrate  $V_BITRATE"
    "━━━━━━━━━━━━━━━"
    " Audio Codec    $A_CODEC"
    " Channels       $A_CHANNELS"
    " Sample Rate    $A_SAMPLERATE"
    " Audio Bitrate  $A_BITRATE"
  )
  values=("$ALL_TEXT" "" "$FORMAT" "$DURATION" "$FILESIZE" "$BITRATE" "" "$V_CODEC" "$V_RES" "$V_FPS" "$V_BITRATE" "" "$A_CODEC" "$A_CHANNELS" "$A_SAMPLERATE" "$A_BITRATE")
  titles=("󰆏 All Info Copied" "" " Format Copied" " Duration Copied" " File Size Copied" " Bitrate Copied" "" " Video Codec Copied" " Resolution Copied" " Frame Rate Copied" " Video Bitrate Copied" "" " Audio Codec Copied" " Channels Copied" " Sample Rate Copied" " Audio Bitrate Copied")
  messages=("Media information copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard")

  # Show in rofi with theme
  SELECTED_INDEX=$(${pkgs.coreutils}/bin/printf '%s\n' "''${labels[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " Media Info" \
    -mesg "🎬 $(one_line "$FILENAME")" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 16;}' \
    -theme-str 'window {width: 600px;}' \
    -format i \
    -no-custom)

  if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ && -n "''${values[$SELECTED_INDEX]-}" ]]; then
    copy_text "''${values[$SELECTED_INDEX]}" "''${titles[$SELECTED_INDEX]}" "''${messages[$SELECTED_INDEX]}"
  fi
''
