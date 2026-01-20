{ pkgs, ... }:
pkgs.writeShellScriptBin "fileinfo-rofi" ''
  # Thunar File Info with Rofi

  FILE="$1"
  rofi_theme="$HOME/.config/rofi/launchers/type-1/style-6.rasi"

  if [[ -z "$FILE" || ! -e "$FILE" ]]; then
    ${pkgs.libnotify}/bin/notify-send "File Info Error" "No valid file selected" -i dialog-error
    exit 1
  fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")
  FILEPATH=$(${pkgs.coreutils}/bin/realpath "$FILE")

  # Get file info
  FILETYPE=$(${pkgs.file}/bin/file -b "$FILE")
  MIMETYPE=$(${pkgs.xdg-utils}/bin/xdg-mime query filetype "$FILE" 2>/dev/null || echo "unknown")
  FILESIZE=$(${pkgs.coreutils}/bin/stat --printf="%s" "$FILE")
  FILESIZE_HR=$(${pkgs.coreutils}/bin/numfmt --to=iec-i --suffix=B "$FILESIZE" 2>/dev/null || echo "$FILESIZE bytes")
  PERMISSIONS=$(${pkgs.coreutils}/bin/stat --printf="%A" "$FILE")
  OWNER=$(${pkgs.coreutils}/bin/stat --printf="%U:%G" "$FILE")
  MODIFIED=$(${pkgs.coreutils}/bin/stat --printf="%y" "$FILE" | ${pkgs.coreutils}/bin/cut -d'.' -f1)
  ACCESSED=$(${pkgs.coreutils}/bin/stat --printf="%x" "$FILE" | ${pkgs.coreutils}/bin/cut -d'.' -f1)
  INODE=$(${pkgs.coreutils}/bin/stat --printf="%i" "$FILE")

  # Build all text for copy
  ALL_TEXT="File: $FILENAME
Type: $FILETYPE
MIME: $MIMETYPE
Size: $FILESIZE_HR ($FILESIZE bytes)
Permissions: $PERMISSIONS
Owner: $OWNER
Modified: $MODIFIED
Accessed: $ACCESSED
Inode: $INODE
Path: $FILEPATH"

  # Build menu
  MENU="󰆏 Copy All Info	copy_all
━━━━━━━━━━━━━━━
 Type	$FILETYPE
 MIME	$MIMETYPE
 Size	$FILESIZE_HR ($FILESIZE bytes)
 Permissions	$PERMISSIONS
 Owner	$OWNER
 Modified	$MODIFIED
 Accessed	$ACCESSED
 Inode	$INODE
 Path	$FILEPATH"

  # Show in rofi with theme
  SELECTED=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " File Info" \
    -mesg "📄 $FILENAME" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 11;}' \
    -theme-str 'window {width: 750px;}' \
    -no-custom)

  if [[ -n "$SELECTED" ]]; then
    ACTION=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $2}')
    if [[ "$ACTION" == "copy_all" ]]; then
      echo -n "$ALL_TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send "󰆏 All Info Copied" "File information copied to clipboard" -i edit-copy
    else
      VALUE="$ACTION"
      LABEL=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $1}' | ${pkgs.gnused}/bin/sed 's/^[^ ]* //')
      echo -n "$VALUE" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send " $LABEL Copied" "Value copied to clipboard" -i edit-copy
    fi
  fi
''
