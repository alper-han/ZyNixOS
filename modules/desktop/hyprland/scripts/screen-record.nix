{ pkgs, ... }:
pkgs.writeShellScriptBin "screen-record" ''
  XDG_VIDEOS_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
  XDG_STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}"
  DIR="''${XDG_VIDEOS_DIR}/screen-record"
  STATE_DIR="''${XDG_STATE_DIR}/screen-record"
  STATE_FILE="''${STATE_DIR}/current-file"

  mkdir -p "$DIR" "$STATE_DIR"

  print_error() {
    cat <<EOF
  Usage: $(basename "$0") <action>
  Valid actions:
    a  : Select area
    m  : Select monitor
  EOF
    exit 1
  }

  if ${pkgs.procps}/bin/pidof wf-recorder > /dev/null; then
    ${pkgs.procps}/bin/pkill wf-recorder
    OUTPUT_FILE="$DIR"
    if [ -f "$STATE_FILE" ]; then
      OUTPUT_FILE=$(<"$STATE_FILE")
      rm -f "$STATE_FILE"
    fi
    ${pkgs.libnotify}/bin/notify-send -e -t 2500 -u low "Recording Finished" \
      "Saved to $OUTPUT_FILE"
    exit 0
  fi

  case "$1" in
    a) REGION=$(${pkgs.slurp}/bin/slurp) ;;
    m) REGION=$(${pkgs.slurp}/bin/slurp -o) ;;
    *) print_error ;;
  esac

  [ -n "$REGION" ] || exit 0

  timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")
  OUTPUT_FILE="$DIR/recording_''${timestamp}.mp4"
  printf '%s\n' "$OUTPUT_FILE" > "$STATE_FILE"

  ${pkgs.libnotify}/bin/notify-send -e -t 2500 -u low "Recording Started" \
    "Saving to $OUTPUT_FILE"

  exec ${pkgs.wf-recorder}/bin/wf-recorder --audio -g "$REGION" -f "$OUTPUT_FILE"
''
