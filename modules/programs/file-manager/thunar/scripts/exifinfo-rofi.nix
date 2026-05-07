{ pkgs, rofiTheme, ... }:
pkgs.writeShellScriptBin "exifinfo-rofi" ''
    # Thunar EXIF Info with Rofi

    FILE="$1"
    rofi_theme="${rofiTheme}"

    if [[ -z "$FILE" || ! -f "$FILE" ]]; then
      ${pkgs.libnotify}/bin/notify-send "EXIF Info Error" "No valid file selected" -i dialog-error
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

    exif_field() {
      local value
    value=$(${pkgs.exiftool}/bin/exiftool -s3 "$1" "$FILE" 2>/dev/null)
    if [[ -n "$value" ]]; then
      one_line "$value"
      else
        ${pkgs.coreutils}/bin/printf 'N/A'
      fi
    }

    # Get key EXIF data
    CAMERA=$(exif_field -Model)
    LENS=$(exif_field -LensModel)
    DATE=$(exif_field -DateTimeOriginal)
    RESOLUTION=$(exif_field -ImageSize)
    ISO=$(exif_field -ISO)
    APERTURE=$(exif_field -Aperture)
    SHUTTER=$(exif_field -ShutterSpeed)
    FOCAL=$(exif_field -FocalLength)
    GPS=$(exif_field -GPSPosition)
    SOFTWARE=$(exif_field -Software)
    COLORSPACE=$(exif_field -ColorSpace)
    FILESIZE=$(exif_field -FileSize)

    # Build all text for copy
    ALL_TEXT="File: $FILENAME
  Resolution: $RESOLUTION
  File Size: $FILESIZE
  Date Taken: $DATE
  ---
  Camera: $CAMERA
  Lens: $LENS
  ---
  ISO: $ISO
  Aperture: $APERTURE
  Shutter: $SHUTTER
  Focal Length: $FOCAL
  ---
  Color Space: $COLORSPACE
  Software: $SOFTWARE
  GPS: $GPS"

  labels=(
    "󰆏 Copy All Info"
    "━━━━━━━━━━━━━━━"
    " Resolution    $RESOLUTION"
    " File Size     $FILESIZE"
    " Date Taken    $DATE"
    "━━━━━━━━━━━━━━━"
    " Camera        $CAMERA"
    " Lens          $LENS"
    "━━━━━━━━━━━━━━━"
    " ISO           $ISO"
    " Aperture      $APERTURE"
    " Shutter       $SHUTTER"
    " Focal Length  $FOCAL"
    "━━━━━━━━━━━━━━━"
    " Color Space   $COLORSPACE"
    " Software      $SOFTWARE"
    " GPS           $GPS"
  )
  values=("$ALL_TEXT" "" "$RESOLUTION" "$FILESIZE" "$DATE" "" "$CAMERA" "$LENS" "" "$ISO" "$APERTURE" "$SHUTTER" "$FOCAL" "" "$COLORSPACE" "$SOFTWARE" "$GPS")
  titles=("󰆏 All Info Copied" "" " Resolution Copied" " File Size Copied" " Date Taken Copied" "" " Camera Copied" " Lens Copied" "" " ISO Copied" " Aperture Copied" " Shutter Copied" " Focal Length Copied" "" " Color Space Copied" " Software Copied" " GPS Copied")
  messages=("EXIF information copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard")

  # Show in rofi with theme
  SELECTED_INDEX=$(${pkgs.coreutils}/bin/printf '%s\n' "''${labels[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " EXIF Info" \
    -mesg "📷 $(one_line "$FILENAME")" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 16;}' \
    -theme-str 'window {width: 550px;}' \
    -format i \
    -no-custom)

  if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ && -n "''${values[$SELECTED_INDEX]-}" ]]; then
    copy_text "''${values[$SELECTED_INDEX]}" "''${titles[$SELECTED_INDEX]}" "''${messages[$SELECTED_INDEX]}"
  fi
''
