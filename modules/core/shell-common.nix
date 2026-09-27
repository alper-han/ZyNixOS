{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    {
      home.sessionVariables.FZF_DEFAULT_OPTS = ''
        --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
        --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
        --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
      '';

      programs.bash = {
        initExtra = ''
          resolve_flake() {
            local flake="''${NH_FLAKE:-}"
            if [[ -z "$flake" ]]; then
              if ! flake="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
                printf '%s\n' 'Error: unable to resolve a flake from the current directory. Set NH_FLAKE or run inside a Git repository.' >&2
                return 1
              fi
            fi
            if [[ "$flake" != /* ]]; then
              flake="$PWD/$flake"
            fi
            if [[ ! -f "$flake/flake.nix" ]]; then
              printf 'Error: resolved flake "%s" does not contain flake.nix. Set NH_FLAKE to a valid flake root.\n' "$flake" >&2
              return 1
            fi
            printf '%s\n' "$flake"
          }

          cdown() {
            if [[ $# -ne 1 || ! $1 =~ ^[0-9]+$ ]]; then
              printf 'usage: cdown <seconds>\n' >&2
              return 2
            fi
            local n=$1
            while (( n > 0 )); do
              printf '%s\n' "$n" | ${pkgs.figlet}/bin/figlet -c | ${pkgs.lolcat}/bin/lolcat
              sleep 1
              (( --n ))
            done
          }

          tms() {
            local session
            session="$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' 2>/dev/null | fzf | cut -d: -f1)"
            [[ -n "$session" ]] || return
            tmux attach -t "$session"
          }

          find-store-path() {
            if [[ $# -ne 1 ]]; then
              printf 'usage: find-store-path <package>\n' >&2
              return 2
            fi
            nix eval --raw "nixpkgs#$1"
          }

          update-input() {
            nix flake update "$@"
          }
        '';
        shellAliases = {
          cls = "clear";
          tml = "tmux list-sessions";
          sysup = ''flake="$(resolve_flake)" && nix flake update --flake "$flake" && rebuild'';
          dots = ''flake="$(resolve_flake)" && cd "$flake"'';
          tma = "tmux attach";
          l = "${pkgs.eza}/bin/eza -lh --icons=auto";
          ls = "${pkgs.eza}/bin/eza -1 --icons=auto";
          ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first";
          ld = "${pkgs.eza}/bin/eza -lhD --icons=auto";
          tree = "${pkgs.eza}/bin/eza --icons=auto --tree";
          cp = "cp -iv";
          mv = "mv -iv";
          rm = "rm -vI";
          bc = "bc -ql";
          mkd = "mkdir -pv";
          tp = "${pkgs.trash-cli}/bin/trash-put";
          tpr = "${pkgs.trash-cli}/bin/trash-restore";
          grep = "grep --color=always";
          list-gens = "nixos-rebuild list-generations";
        };
      };

      programs.zsh = {
        initContent = lib.mkOrder 500 ''
          resolve_flake() {
            local flake="''${NH_FLAKE:-}"
            if [[ -z "$flake" ]]; then
              if ! flake="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
                print -u2 'Error: unable to resolve a flake from the current directory. Set NH_FLAKE or run inside a Git repository.'
                return 1
              fi
            fi
            if [[ "$flake" != /* ]]; then
              flake="$PWD/$flake"
            fi
            if [[ ! -f "$flake/flake.nix" ]]; then
              printf 'Error: resolved flake "%s" does not contain flake.nix. Set NH_FLAKE to a valid flake root.\n' "$flake" >&2
              return 1
            fi
            printf '%s\n' "$flake"
          }

          cdown() {
            if [[ $# -ne 1 || $1 != <-> ]]; then
              print -u2 "usage: cdown <seconds>"
              return 2
            fi
            local n=$1
            while (( n > 0 )); do
              printf '%s\n' "$n" | ${pkgs.figlet}/bin/figlet -c | ${pkgs.lolcat}/bin/lolcat
              sleep 1
              (( --n ))
            done
          }

          tms() {
            local session
            session="$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' 2>/dev/null | fzf | cut -d: -f1)"
            [[ -n "$session" ]] || return
            tmux attach -t "$session"
          }

          find-store-path() {
            if [[ $# -ne 1 ]]; then
              print -u2 "usage: find-store-path <package>"
              return 2
            fi
            nix eval --raw "nixpkgs#$1"
          }

          update-input() {
            nix flake update "$@"
          }
        '';
        shellAliases = {
          cls = "clear";
          tml = "tmux list-sessions";
          tma = "tmux attach";
          l = "${pkgs.eza}/bin/eza -lh --icons=auto";
          ls = "${pkgs.eza}/bin/eza -1 --icons=auto";
          ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first";
          ld = "${pkgs.eza}/bin/eza -lhD --icons=auto";
          tree = "${pkgs.eza}/bin/eza --icons=auto --tree";
          cp = "cp -iv";
          mv = "mv -iv";
          rm = "rm -vI";
          bc = "bc -ql";
          mkd = "mkdir -pv";
          tp = "${pkgs.trash-cli}/bin/trash-put";
          tpr = "${pkgs.trash-cli}/bin/trash-restore";
          grep = "grep --color=always";
          list-gens = "nixos-rebuild list-generations";
          sysup = ''flake="$(resolve_flake)" && nix flake update --flake "$flake" && rebuild'';
          dots = ''flake="$(resolve_flake)" && cd "$flake"'';
        };
      };
    }
  ];
}
