{ pkgs, rofiTheme, ... }:
pkgs.writeShellScriptBin "fileinfo-rofi" ''
    # Thunar File Info with Rofi

    FILE="$1"
    rofi_theme="${rofiTheme}"

    if [[ -z "$FILE" || ! -e "$FILE" ]]; then
      ${pkgs.libnotify}/bin/notify-send "File Info Error" "No valid file selected" -i dialog-error
      exit 1
    fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")
  FILEPATH=$(${pkgs.coreutils}/bin/realpath "$FILE")

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

    # Get file info
  FILETYPE=$(${pkgs.file}/bin/file -b "$FILE")
  MIMETYPE=$(${pkgs.xdg-utils}/bin/xdg-mime query filetype "$FILE" 2>/dev/null)
  [[ -n "$MIMETYPE" ]] || MIMETYPE="unknown"
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

  labels=(
    "󰆏 Copy All Info"
    "━━━━━━━━━━━━━━━"
    " Type         $(one_line "$FILETYPE")"
    " MIME         $(one_line "$MIMETYPE")"
    " Size         $(one_line "$FILESIZE_HR ($FILESIZE bytes)")"
    " Permissions  $(one_line "$PERMISSIONS")"
    " Owner        $(one_line "$OWNER")"
    " Modified     $(one_line "$MODIFIED")"
    " Accessed     $(one_line "$ACCESSED")"
    " Inode        $(one_line "$INODE")"
    " Path         $(one_line "$FILEPATH")"
  )
  values=("$ALL_TEXT" "" "$FILETYPE" "$MIMETYPE" "$FILESIZE_HR ($FILESIZE bytes)" "$PERMISSIONS" "$OWNER" "$MODIFIED" "$ACCESSED" "$INODE" "$FILEPATH")
  titles=("󰆏 All Info Copied" "" " Type Copied" " MIME Copied" " Size Copied" " Permissions Copied" " Owner Copied" " Modified Copied" " Accessed Copied" " Inode Copied" " Path Copied")
  messages=("File information copied to clipboard" "" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard" "Value copied to clipboard")

  # Show in rofi with theme
  SELECTED_INDEX=$(${pkgs.coreutils}/bin/printf '%s\n' "''${labels[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " File Info" \
    -mesg "📄 $(one_line "$FILENAME")" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 11;}' \
    -theme-str 'window {width: 750px;}' \
    -format i \
    -no-custom)

  if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ && -n "''${values[$SELECTED_INDEX]-}" ]]; then
    copy_text "''${values[$SELECTED_INDEX]}" "''${titles[$SELECTED_INDEX]}" "''${messages[$SELECTED_INDEX]}"
  fi
''
