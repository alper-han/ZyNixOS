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
          sysup = "nix flake update --flake ~/ZyNixOS && rebuild";
          dots = "cd ~/ZyNixOS/";
        };
      };

      programs.zsh = {
        initContent = lib.mkOrder 500 ''

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
          sysup = "nix flake update --flake ~/ZyNixOS && rebuild";
          dots = "cd ~/ZyNixOS/";
        };
      };
    }
  ];
}
