{ pkgs, ... }:
pkgs.writeShellScriptBin "rofimusic" ''
  if ${pkgs.procps}/bin/pidof rofi > /dev/null; then
    ${pkgs.procps}/bin/pkill rofi
    exit 0
  fi

  iDIR="$HOME/.config/hypr/icons"

  declare -A shuffle=(
    ["Pop 📻🎶"]="https://youtube.com/playlist?list=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj"
    ["Dance 📻🎶"]="https://dancewave.online:443/dance.mp3"
    ["Lofi Radio ☕️🎶"]="https://play.streamafrica.net/lofiradio"
    ["96.3 Easy Rock 📻🎶"]="https://radio-stations-philippines.com/easy-rock"
    ["Rock 📻🎶"]="https://www.youtube.com/playlist?list=PL6Lt9p1lIRZ311J9ZHuzkR5A3xesae2pk"
    ["Ghibli Music 🎻🎶"]="https://youtube.com/playlist?list=PLNi74S754EXbrzw-IzVhpeAaMISNrzfUy&si=rqnXCZU5xoFhxfOl"
    ["Top Youtube Music 2023 ☕️🎶"]="https://youtube.com/playlist?list=PLDIoUOhQQPlXr63I_vwF9GD8sAKh77dWU&si=y7qNeEVFNgA-XxKy"
    ["Chillhop ☕️🎶"]="https://stream.zeno.fm/fyn8eh3h5f8uv"
    ["SmoothChill ☕️🎶"]="https://media-ssl.musicradio.com/SmoothChill"
    ["Smooth UK ☕️🎶"]="https://icecast.thisisdax.com/SmoothUKMP3"
    ["Relaxing Music ☕️🎶"]="https://youtube.com/playlist?list=PLMIbmfP_9vb8BCxRoraJpoo4q1yMFg4CE"
    ["Youtube Remix 📻🎶"]="https://youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
    ["_Headbangers 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL27g7BfUwAEoBr2Cr5EY0aP8"
    ["_Motorway 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL2613eXf-20WT6VQnZenrg0X"
    ["_Carriageway 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL26qNYOBo0_9yW9za1Egwp_y"
    ["_Classics 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL260MDLEfAej9CqFqdycTf3X"
    ["_Metal 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL246iFzN3q8-cYCA43YBxv_z"
    ["_Limo 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL27x3iZrv2ElvTK7-iQzQKYY"
    ["_80s 90s 2000s 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL24FAtYVcivVfHImRsu-ocj4"
    ["_Hard Rock 🎵"]="https://youtube.com/playlist?list=PLLosUj2DlL25A5u32lnZXtc_AUy-u2AUd"
  )

  declare -A menu_options
  for key in "''${!shuffle[@]}"; do menu_options["$key"]="''${shuffle[$key]}"; done

  notification() {
    ${pkgs.libnotify}/bin/notify-send -e -t 2500 -u normal -i "$iDIR/music.png" "Playing now: $1"
  }

  main() {
    r_override="entry{placeholder:'Search Music...';}listview{lines:10;}"
    choice=$(printf "%s\n" "''${!menu_options[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -theme-str "$r_override" -theme ~/.config/rofi/launchers/type-2/style-2.rasi -i -p "")

    if [ -z "$choice" ]; then
      exit 1
    fi

    link="''${menu_options[$choice]}"

    notification "$choice"

    if [[ $link == *playlist* ]]; then
      exec uwsm app -- ${pkgs.mpv}/bin/mpv --vid=no --shuffle "$link"
    else
      exec uwsm app -- ${pkgs.mpv}/bin/mpv "$link"
    fi
  }

  ${pkgs.procps}/bin/pkill mpv && ${pkgs.libnotify}/bin/notify-send -e -t 2500 -u low -i "$iDIR/music.png" "Playback stopped" || main
''
