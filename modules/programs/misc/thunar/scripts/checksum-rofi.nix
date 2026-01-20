{ pkgs, ... }:
pkgs.writeShellScriptBin "checksum-rofi" ''
  # Thunar Checksum with Rofi
  # Usage: checksum-rofi <file> <algorithm>
  # algorithm: sha256, sha512, blake3, md5, sha1, all

  FILE="$1"
  ALGO="$2"
  rofi_theme="$HOME/.config/rofi/launchers/type-1/style-6.rasi"

  if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    ${pkgs.libnotify}/bin/notify-send "Checksum Error" "No valid file selected" -i dialog-error
    exit 1
  fi

  FILENAME=$(${pkgs.coreutils}/bin/basename "$FILE")

  calculate_hash() {
    local cmd="$1"
    local file="$2"
    if [[ "$cmd" == "b3sum" ]]; then
      ${pkgs.b3sum}/bin/b3sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1 || echo "N/A (b3sum not installed)"
    elif [[ "$cmd" == "sha256sum" ]]; then
      ${pkgs.coreutils}/bin/sha256sum "$file" | ${pkgs.coreutils}/bin/cut -d' ' -f1
    elif [[ "$cmd" == "sha512sum" ]]; then
      ${pkgs.coreutils}/bin/sha512sum "$file" | ${pkgs.coreutils}/bin/cut -d' ' -f1
    elif [[ "$cmd" == "md5sum" ]]; then
      ${pkgs.coreutils}/bin/md5sum "$file" | ${pkgs.coreutils}/bin/cut -d' ' -f1
    elif [[ "$cmd" == "sha1sum" ]]; then
      ${pkgs.coreutils}/bin/sha1sum "$file" | ${pkgs.coreutils}/bin/cut -d' ' -f1
    fi
  }

  case "$ALGO" in
    sha256)
      HASH=$(calculate_hash sha256sum "$FILE")
      ALGO_NAME="SHA256"
      ;;
    sha512)
      HASH=$(calculate_hash sha512sum "$FILE")
      ALGO_NAME="SHA512"
      ;;
    blake3)
      HASH=$(calculate_hash b3sum "$FILE")
      ALGO_NAME="BLAKE3"
      ;;
    md5)
      HASH=$(calculate_hash md5sum "$FILE")
      ALGO_NAME="MD5"
      ;;
    sha1)
      HASH=$(calculate_hash sha1sum "$FILE")
      ALGO_NAME="SHA1"
      ;;
    all)
      SHA256=$(calculate_hash sha256sum "$FILE")
      SHA512=$(calculate_hash sha512sum "$FILE")
      BLAKE3=$(calculate_hash b3sum "$FILE")
      MD5=$(calculate_hash md5sum "$FILE")
      SHA1=$(calculate_hash sha1sum "$FILE")

      ALL_TEXT="SHA256: $SHA256
SHA512: $SHA512
BLAKE3: $BLAKE3
MD5: $MD5
SHA1: $SHA1"

      RESULT_MENU="󰆏 Copy All	copy_all
━━━━━━━━━━━━━━━
󰒃 SHA256	$SHA256
󰒃 SHA512	$SHA512
󰒃 BLAKE3	$BLAKE3
󰒃 MD5	$MD5
󰒃 SHA1	$SHA1"

      SELECTED=$(echo -e "$RESULT_MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i \
        -p " All Checksums" \
        -mesg "📁 $FILENAME" \
        -theme "$rofi_theme" \
        -theme-str 'listview {lines: 7;}' \
        -theme-str 'window {width: 750px;}' \
        -no-custom)

      if [[ -n "$SELECTED" ]]; then
        ACTION=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $2}')
        if [[ "$ACTION" == "copy_all" ]]; then
          echo -n "$ALL_TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
          ${pkgs.libnotify}/bin/notify-send "󰆏 All Checksums Copied" "All 5 checksums copied to clipboard" -i edit-copy
        else
          HASH="$ACTION"
          ALGO_SEL=$(echo "$SELECTED" | ${pkgs.gawk}/bin/awk -F'\t' '{print $1}' | ${pkgs.gnused}/bin/sed 's/^[^ ]* //')
          echo -n "$HASH" | ${pkgs.wl-clipboard}/bin/wl-copy
          ${pkgs.libnotify}/bin/notify-send " $ALGO_SEL Copied" "''${HASH:0:32}..." -i edit-copy
        fi
      fi
      exit 0
      ;;
    *)
      ${pkgs.libnotify}/bin/notify-send "Checksum Error" "Unknown algorithm: $ALGO" -i dialog-error
      exit 1
      ;;
  esac

  # Single checksum result
  RESULT_MENU="󰆏 Copy Hash	$HASH"

  SELECTED=$(echo -e "$RESULT_MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i \
    -p " $ALGO_NAME" \
    -mesg "📁 $FILENAME

$HASH" \
    -theme "$rofi_theme" \
    -theme-str 'listview {lines: 1;}' \
    -theme-str 'window {width: 750px;}' \
    -no-custom)

  if [[ -n "$SELECTED" ]]; then
    echo -n "$HASH" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send " $ALGO_NAME Copied" "''${HASH:0:32}..." -i edit-copy
  fi
''
