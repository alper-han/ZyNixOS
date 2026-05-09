{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "zynix-games-catalog";
  runtimeInputs = with pkgs; [
    coreutils
    findutils
    gnugrep
    gnused
    jq
  ];
  text = ''
    set -o pipefail

    desktop_field() {
      local field="$1"
      local file="$2"

      sed -n "s/^''${field}=//p" "$file" | sed -n '1p'
    }

    clean_desktop_exec() {
      printf '%s' "$1" | sed -E 's/(^|[[:space:]])%[fFuUdDnNickvm]($|[[:space:]])/ /g; s/[[:space:]]+/ /g; s/^ //; s/ $//'
    }

    emit_game() {
      local name="$1"
      local source="$2"
      local icon="$3"
      local icon_path="$4"
      local command_json="$5"

      if [[ -z "$name" || -z "$command_json" ]]; then
        return 0
      fi

      jq -cn \
        --arg name "$name" \
        --arg source "$source" \
        --arg icon "''${icon:-sports_esports}" \
        --arg iconPath "$icon_path" \
        --argjson command "$command_json" \
        '{name:$name, source:$source, icon:$icon, iconPath:$iconPath, command:$command}'
    }

    scan_desktop_entries() {
      local data_dir
      local app_dir
      local desktop
      local name
      local categories
      local exec_value
      local icon
      local command_json

      IFS=: read -r -a data_dirs <<< "''${XDG_DATA_DIRS:-}"
      data_dirs+=("$HOME/.local/share" "/run/current-system/sw/share")

      for data_dir in "''${data_dirs[@]}"; do
        [[ -n "$data_dir" ]] || continue
        app_dir="$data_dir/applications"
        [[ -d "$app_dir" ]] || continue

        while IFS= read -r -d "" desktop; do
          if [[ "$(desktop_field NoDisplay "$desktop" | tr '[:upper:]' '[:lower:]')" == true ]]; then
            continue
          fi

          categories="$(desktop_field Categories "$desktop")"
          [[ "$categories" == *Game* ]] || continue

          name="$(desktop_field Name "$desktop")"
          [[ -n "$name" ]] || name="$(basename "$desktop" .desktop)"
          if [[ "''${name,,}" == steam || "$(basename "$desktop")" == steam.desktop ]]; then
            continue
          fi

          exec_value="$(clean_desktop_exec "$(desktop_field Exec "$desktop")")"
          [[ -n "$exec_value" ]] || continue

          icon="$(desktop_field Icon "$desktop")"
          command_json="$(jq -cn --arg execValue "$exec_value" '["uwsm", "app", "--", "sh", "-lc", $execValue]')"
          emit_game "$name" "Desktop Entry" "''${icon:-sports_esports}" "" "$command_json"
        done < <(find "$app_dir" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)
      done
    }

    vdf_value() {
      local key="$1"
      local file="$2"

      sed -nE "s/.*\"''${key}\"[[:space:]]+\"([^\"]+)\".*/\1/p" "$file" | sed -n '1p'
    }

    scan_steam_library() {
      local library_file="$1"
      local library_root
      local library
      local steamapps
      local steam_root
      local manifest
      local appid
      local name
      local lowered_name
      local icon_path
      local candidate
      local command_json

      library_root="$(dirname "$(dirname "$library_file")")"
      printf '%s\0' "$library_root"
      sed -nE 's/.*"path"[[:space:]]+"([^"]+)".*/\1/p' "$library_file" | sed 's/\\\\/\\/g' | while IFS= read -r library; do
        [[ -n "$library" ]] && printf '%s\0' "$library"
      done
    }

    scan_steam_entries() {
      local steam_root
      local library_file

      for steam_root in \
        "$HOME/.local/share/Steam" \
        "$HOME/.steam/steam" \
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"; do
        library_file="$steam_root/steamapps/libraryfolders.vdf"
        [[ -f "$library_file" ]] || continue

        while IFS= read -r -d "" library; do
          steamapps="$library/steamapps"
          [[ -d "$steamapps" ]] || continue
          steam_root="$(dirname "$steamapps")"

          while IFS= read -r -d "" manifest; do
            appid="$(vdf_value appid "$manifest")"
            name="$(vdf_value name "$manifest")"
            [[ -n "$appid" && -n "$name" ]] || continue

            lowered_name="''${name,,}"
            if [[ "$lowered_name" == *proton* \
              || "$lowered_name" == *"steam linux runtime"* \
              || "$lowered_name" == *"steamworks common redistributables"* ]]; then
              continue
            fi

            icon_path=""
            for candidate in \
              "$steam_root/appcache/librarycache/''${appid}_icon.jpg" \
              "$steam_root/appcache/librarycache/''${appid}_icon.png" \
              "$steam_root/appcache/librarycache/''${appid}_library_600x900.jpg" \
              "$steam_root/appcache/librarycache/''${appid}_header.jpg"; do
              if [[ -f "$candidate" ]]; then
                icon_path="$candidate"
                break
              fi
            done

            command_json="$(jq -cn --arg appid "$appid" '["uwsm", "app", "--", "steam", "steam://rungameid/" + $appid]')"
            emit_game "$name" "Steam Library" steam "$icon_path" "$command_json"
          done < <(find "$steamapps" -maxdepth 1 -type f -name 'appmanifest_*.acf' -print0 2>/dev/null)
        done < <(scan_steam_library "$library_file")
      done
    }

    {
      scan_desktop_entries
      scan_steam_entries
    } | jq -s 'unique_by([.name, .command]) | sort_by(.name | ascii_downcase)'
  '';
}
