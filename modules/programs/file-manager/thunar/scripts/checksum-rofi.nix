{ pkgs, rofiTheme, ... }:
pkgs.writeShellScriptBin "checksum-rofi" ''
      # Thunar Checksum with Rofi
      # Usage: checksum-rofi <file> <algorithm>
      # algorithm: sha256, sha512, blake3, md5, sha1, all

      FILE="$1"
      ALGO="$2"
      rofi_theme="${rofiTheme}"

      if [[ -z "$FILE" || ! -f "$FILE" ]]; then
        ${pkgs.libnotify}/bin/notify-send "Checksum Error" "No valid file selected" -i dialog-error
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

    calculate_hash() {
      local cmd="$1"
      local file="$2"
      local hash=""

      case "$cmd" in
        b3sum)
          hash=$(${pkgs.b3sum}/bin/b3sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1)
          ;;
        sha256sum)
          hash=$(${pkgs.coreutils}/bin/sha256sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1)
          ;;
        sha512sum)
          hash=$(${pkgs.coreutils}/bin/sha512sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1)
          ;;
        md5sum)
          hash=$(${pkgs.coreutils}/bin/md5sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1)
          ;;
        sha1sum)
          hash=$(${pkgs.coreutils}/bin/sha1sum "$file" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d' ' -f1)
          ;;
      esac

      if [[ -n "$hash" ]]; then
        ${pkgs.coreutils}/bin/printf '%s' "$hash"
      else
        ${pkgs.coreutils}/bin/printf 'N/A (could not read file)'
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

        labels=(
          "󰆏 Copy All"
          "━━━━━━━━━━━━━━━"
          "󰒃 SHA256  $(one_line "$SHA256")"
          "󰒃 SHA512  $(one_line "$SHA512")"
          "󰒃 BLAKE3  $(one_line "$BLAKE3")"
          "󰒃 MD5     $(one_line "$MD5")"
          "󰒃 SHA1    $(one_line "$SHA1")"
        )
        values=("$ALL_TEXT" "" "$SHA256" "$SHA512" "$BLAKE3" "$MD5" "$SHA1")
        titles=("󰆏 All Checksums Copied" "" " SHA256 Copied" " SHA512 Copied" " BLAKE3 Copied" " MD5 Copied" " SHA1 Copied")
        messages=(
          "All 5 checksums copied to clipboard"
          ""
          "''${SHA256:0:32}..."
          "''${SHA512:0:32}..."
          "''${BLAKE3:0:32}..."
          "''${MD5:0:32}..."
          "''${SHA1:0:32}..."
        )

        SELECTED_INDEX=$(${pkgs.coreutils}/bin/printf '%s\n' "''${labels[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i \
          -p " All Checksums" \
          -mesg "📁 $(one_line "$FILENAME")" \
          -theme "$rofi_theme" \
          -theme-str 'listview {lines: 7;}' \
          -theme-str 'window {width: 750px;}' \
          -format i \
          -no-custom)

        if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ && -n "''${values[$SELECTED_INDEX]-}" ]]; then
          copy_text "''${values[$SELECTED_INDEX]}" "''${titles[$SELECTED_INDEX]}" "''${messages[$SELECTED_INDEX]}"
        fi
        exit 0
          ;;
        *)
          ${pkgs.libnotify}/bin/notify-send "Checksum Error" "Unknown algorithm: $ALGO" -i dialog-error
          exit 1
          ;;
      esac

      # Single checksum result
    labels=("󰆏 Copy Hash")
    values=("$HASH")

    SELECTED_INDEX=$(${pkgs.coreutils}/bin/printf '%s\n' "''${labels[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i \
      -p " $ALGO_NAME" \
      -mesg "📁 $(one_line "$FILENAME")

  $HASH" \
      -theme "$rofi_theme" \
      -theme-str 'listview {lines: 1;}' \
      -theme-str 'window {width: 750px;}' \
      -format i \
      -no-custom)

    if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ && -n "''${values[$SELECTED_INDEX]-}" ]]; then
      copy_text "''${values[$SELECTED_INDEX]}" " $ALGO_NAME Copied" "''${HASH:0:32}..."
    fi
''
