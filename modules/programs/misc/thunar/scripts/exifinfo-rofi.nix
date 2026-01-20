{ pkgs, ... }:
pkgs.writeShellScriptBin "exifinfo-rofi" ''
  # Thunar EXIF Info with Rofi

  FILE="$1"
  rofi_theme="$HOME/.config/rofi/launchers/type-1/style-6.rasi"

  if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    ${pkgs.libnotify}/bin/notify-send "EXIF Info Error" "No valid file selected" -i dialog-error
    exit 1
  fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")

  # Get key EXIF data
  CAMERA=$(${pkgs.exiftool}/bin/exiftool -s3 -Model "$FILE" 2>/dev/null || echo "N/A")
  LENS=$(${pkgs.exiftool}/bin/exiftool -s3 -LensModel "$FILE" 2>/dev/null || echo "N/A")
  DATE=$(${pkgs.exiftool}/bin/exiftool -s3 -DateTimeOriginal "$FILE" 2>/dev/null || echo "N/A")
  RESOLUTION=$(${pkgs.exiftool}/bin/exiftool -s3 -ImageSize "$FILE" 2>/dev/null || echo "N/A")
  ISO=$(${pkgs.exiftool}/bin/exiftool -s3 -ISO "$FILE" 2>/dev/null || echo "N/A")
  APERTURE=$(${pkgs.exiftool}/bin/exiftool -s3 -Aperture "$FILE" 2>/dev/null || echo "N/A")
  SHUTTER=$(${pkgs.exiftool}/bin/exiftool -s3 -ShutterSpeed "$FILE" 2>/dev/null || echo "N/A")
  FOCAL=$(${pkgs.exiftool}/bin/exiftool -s3 -FocalLength "$FILE" 2>/dev/null || echo "N/A")
  GPS=$(${pkgs.exiftool}/bin/exiftool -s3 -GPSPosition "$FILE" 2>/dev/null || echo "N/A")
  SOFTWARE=$(${pkgs.exiftool}/bin/exiftool -s3 -Software "$FILE" 2>/dev/null || echo "N/A")
  COLORSPACE=$(${pkgs.exiftool}/bin/exiftool -s3 -ColorSpace "$FILE" 2>/dev/null || echo "N/A")
  FILESIZE=$(${pkgs.exiftool}/bin/exiftool -s3 -FileSize "$FILE" 2>/dev/null || echo "N/A")

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

  # Build menu with icons
  MENU="󰆏 Copy All Info	copy_all
━━━━━━━━━━━━━━━
 Resolution	$RESOLUTION
 File Size	$FILESIZE
 Date Taken	$DATE
━━━━━━━━━━━━━━━
 Camera	$CAMERA
 Lens	$LENS
━━━━━━━━━━━━━━━
 ISO	$ISO
 Aperture	$APERTURE
 Shutter	$SHUTTER
 Focal Length	$FOCAL
━━━━━━━━━━━━━━━
 Color Space	$COLORSPACE
 Software	$SOFTWARE
 GPS	$GPS"

  # Show in rofi with theme
  SELECTED=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " EXIF Info" \
    -mesg "📷 $FILENAME" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 16;}' \
    -theme-str 'window {width: 550px;}' \
    -no-custom)

  if [[ -n "$SELECTED" ]]; then
    ACTION=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $2}')
    if [[ "$ACTION" == "copy_all" ]]; then
      echo -n "$ALL_TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send "󰆏 All Info Copied" "EXIF information copied to clipboard" -i edit-copy
    else
      VALUE="$ACTION"
      LABEL=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $1}' | ${pkgs.gnused}/bin/sed 's/^[^ ]* //')
      echo -n "$VALUE" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send " $LABEL Copied" "Value copied to clipboard" -i edit-copy
    fi
  fi
''
