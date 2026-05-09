{ pkgs, ... }:
pkgs.writeShellScriptBin "screenshot" ''
  swpy_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/swappy"
  XDG_PICTURES_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}"
  save_dir="''${XDG_PICTURES_DIR}/Screenshots"

  mkdir -p "$save_dir"
  mkdir -p "$swpy_dir"

  print_error() {
    cat << EOF
  Usage: $(basename "$0") <action>
  Valid actions:
    p  : Print all screens to clipboard
    s  : Snip area, edit in Swappy, save, and copy
    sf : Snip area frozen, edit in Swappy, save, and copy
    m  : Print focused monitor to clipboard
    test-copy <file> : Copy an image file to the clipboard
  EOF
    exit 1
  }

  copy_to_clipboard() {
    local image_file="$1"

    ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < "$image_file"
  }

  notify_copied() {
    local image_file="$1"

    ${pkgs.libnotify}/bin/notify-send -a Screenshot \
                -i "$image_file" \
                "Screenshot Copied" \
                "$(basename "$image_file")"
  }

  take_selected_screenshot() {
    local save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"
    local save_path="''${save_dir}/''${save_file}"

    cat > "$swpy_dir/config" << EOF
  [Default]
  save_dir=$save_dir
  save_filename_format=$save_file
  EOF

    case "$1" in
      area)   ${pkgs.grimblast}/bin/grimblast save area - | ${pkgs.swappy}/bin/swappy -f - -o "$save_path" ;;
      freeze) ${pkgs.grimblast}/bin/grimblast --freeze save area - | ${pkgs.swappy}/bin/swappy -f - -o "$save_path" ;;
    esac

    if [ -f "$save_path" ]; then
      copy_to_clipboard "$save_path"

      ${pkgs.libnotify}/bin/notify-send -a Screenshot \
                  -i "$save_path" \
                  "Screenshot Saved & Copied" \
                  "$(basename "$save_file")"
    fi
  }

  copy_screenshot() {
    local save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"
    local save_path="''${save_dir}/''${save_file}"

    case "$1" in
      screen) ${pkgs.grimblast}/bin/grimblast save screen "$save_path" ;;
      output) ${pkgs.grimblast}/bin/grimblast save output "$save_path" ;;
    esac

    if [ -f "$save_path" ]; then
      copy_to_clipboard "$save_path"
      notify_copied "$save_path"
    fi
  }

  case "$1" in
    p)  copy_screenshot screen ;;
    s)  take_selected_screenshot area ;;
    sf) take_selected_screenshot freeze ;;
    m)  copy_screenshot output ;;
    test-copy) copy_to_clipboard "$2" ;;
    *)  print_error ;;
  esac
''
