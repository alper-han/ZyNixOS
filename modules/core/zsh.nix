{ self, pkgs, lib, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          enableCompletion = true;
          history.size = 100000;
          history.path = "\${XDG_DATA_HOME}/zsh/history";
          dotDir = "${config.xdg.configHome}/zsh";
          initContent = lib.mkMerge [
            (lib.mkOrder 550 ''
            fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions $fpath)

            # Completion styles are configured before Home Manager runs compinit.
            zstyle ":completion:*" menu no
            zstyle ":completion:*" list-colors "''${(s.:.)LS_COLORS}"
            zstyle ":completion:*" verbose yes
            zstyle ":completion:*:descriptions" format "%F{yellow}-- %d --%f"
            zstyle ":completion:*:messages" format "%F{purple}-- %d --%f"
            zstyle ":completion:*:warnings" format "%F{red}-- no matches found --%f"
            zstyle ":completion:*" group-name ""
            zstyle ":completion:*:*:-command-:*:*" group-order aliases builtins functions commands
            zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
            zstyle ":completion:*" extra-verbose yes
            zstyle ":completion:*" use-cache on
            zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
            zstyle ":completion:*" file-list all
            zstyle ":completion:*:options" description yes
            zstyle ":completion:*:options" auto-description "%d"
            '')

            (lib.mkOrder 650 ''
            # fzf-tab must load after compinit and before widget-wrapping plugins.
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            '')

            (lib.mkOrder 1000 ''
            # Keep history substring search available, but do not own arrow keys for now.
            source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

            # Sudo widget (double ESC to prepend sudo - replaces oh-my-zsh sudo plugin)
            sudo-command-line() {
              [[ -z $BUFFER ]] && zle up-history
              if [[ $BUFFER == sudo\ * ]]; then
                LBUFFER="''${LBUFFER#sudo }"
              else
                LBUFFER="sudo $LBUFFER"
              fi
            }
            zle -N sudo-command-line
            bindkey '\e\e' sudo-command-line

            # Key Bindings
            bindkey '^a' beginning-of-line
            bindkey '^e' end-of-line

            # Options
            unsetopt menu_complete
            unsetopt flowcontrol

            setopt prompt_subst
            setopt always_to_end
            setopt append_history
            setopt auto_menu
            setopt complete_in_word
            setopt extended_history
            setopt hist_expire_dups_first
            setopt hist_ignore_dups
            setopt hist_ignore_space
            setopt hist_verify
            setopt inc_append_history
            setopt share_history

            lf() {
              local tmp dir
              tmp="$(mktemp)" || return
              ${pkgs.lf}/bin/lf -last-dir-path="$tmp" "$@"
              if [[ -f $tmp ]]; then
                dir="$(<"$tmp")"
                rm -f "$tmp"
                if [[ -d $dir && $dir != "$PWD" ]]; then
                  cd "$dir"
                fi
              fi
            }

            fnew() {
              if [[ $# -ne 2 ]]; then
                print -u2 "usage: fnew <template> <directory>"
                return 2
              fi
              if [[ -d $2 ]]; then
                print -u2 "Directory \"$2\" already exists!"
                return 1
              fi
              nix flake new "$2" --template ${self}/dev-shells#$1
              cd "$2"
              direnv allow
            }

            finit() {
              if [[ $# -ne 1 ]]; then
                print -u2 "usage: finit <template>"
                return 2
              fi
              nix flake init --template ${self}/dev-shells#$1
              direnv allow
            }

            cdown() {
              if [[ $# -ne 1 || $1 != <-> ]]; then
                print -u2 "usage: cdown <seconds>"
                return 2
              fi
              local n=$1
              while (( n > 0 )); do
                echo "$n" | ${pkgs.figlet}/bin/figlet -c | ${pkgs.lolcat}/bin/lolcat
                sleep 1
                (( --n ))
              done
              return 0
            }

            tms() {
              local session
              session="$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' 2>/dev/null | fzf | cut -d: -f1)"
              [[ -n $session ]] || return
              tmux attach -t "$session"
            }

            find-store-path() {
              if [[ $# -ne 1 ]]; then
                print -u2 "usage: find-store-path <package>"
                return 2
              fi
              nix-shell -p "$1" --command "nix eval -f \"<nixpkgs>\" --raw $1"
            }

            update-input() {
              nix flake update "$@"
            }
            '')
          ];
          envExtra = ''
            # Defaults
            export XMONAD_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/xmonad" # xmonad.hs is expected to stay here
            export XMONAD_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/xmonad"
            export XMONAD_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/xmonad"

            export FZF_DEFAULT_OPTS=" \
            --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
            --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
            --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
          '';
          shellGlobalAliases = {
            UUID = "$(uuidgen | tr -d \\n)";
            G = "| grep";
          };
          shellAliases = {
            cls = "clear";
            tml = "tmux list-sessions";
            tma = "tmux attach";
            l = "${pkgs.eza}/bin/eza -lh  --icons=auto"; # long list
            ls = "${pkgs.eza}/bin/eza -1   --icons=auto"; # short list
            ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first"; # long list all
            ld = "${pkgs.eza}/bin/eza -lhD --icons=auto"; # long list dirs
            tree = "${pkgs.eza}/bin/eza --icons=auto --tree"; # dir tree
            vc = "$EDITOR"; # configured gui/code editor
            nv = "$EDITOR";
            nf = "${pkgs.microfetch}/bin/microfetch";
            ff = ''${pkgs.fastfetch}/bin/fastfetch --logo "$(find ~/.config/fastfetch/pngs/ -name '*.png' | shuf -n 1)"'';
            cp = "cp -iv";
            mv = "mv -iv";
            rm = "rm -vI";
            bc = "bc -ql";
            mkd = "mkdir -pv";
            tp = "${pkgs.trash-cli}/bin/trash-put";
            tpr = "${pkgs.trash-cli}/bin/trash-restore";
            grep = "grep --color=always";

            # Nixos
            list-gens = "nixos-rebuild list-generations";
            sysup = "nix flake update --flake ~/ZyNixOS && rebuild";

            # Directory Shortcuts.
            dots = "cd ~/ZyNixOS/";
          };
        };
      }
    )
  ];
}
