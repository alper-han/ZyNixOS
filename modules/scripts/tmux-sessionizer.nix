{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "tmux-sessionizer" ''
  set -euo pipefail
  tmux="${pkgs.tmux}/bin/tmux"
  fzf="${pkgs.fzf}/bin/fzf"

  if [[ $# -eq 1 ]]; then
      selected="$1"
  else
      # Quote the command to preserve spaces in paths
      selected="$(${lib.getExe pkgs.fd} --min-depth 1 --max-depth 1 --type d . ~/ ~/Documents/ ~/git-clone/ /mnt/ /mnt/*/Projects/ /mnt/*/Media/ /mnt/*/Pimsleur/ /mnt/*/Languages/ | "$fzf" || true)"
      if [[ -z "$selected" ]]; then
          exit 0
      fi
      selected=$(realpath -- "$selected")
  fi

  if [[ -z "$selected" ]]; then
      exit 0
  fi

  selected_name=$(basename "$selected" | tr ' ' '-')


  if [[ -z "''${TMUX:-}" ]]; then
      exec "$tmux" new-session -A -s "$selected_name" -c "$selected"
  fi

  if ! "$tmux" has-session -t="$selected_name" 2> /dev/null; then
      "$tmux" new-session -ds "$selected_name" -c "$selected"
  fi

  "$tmux" switch-client -t "$selected_name"
''
