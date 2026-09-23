{
  pkgs,
  lib,
  ...
}:
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

              bindkey '^a' beginning-of-line
              bindkey '^e' end-of-line
              unsetopt menu_complete
              unsetopt flowcontrol
              setopt prompt_subst
              setopt always_to_end
              setopt auto_menu
              setopt complete_in_word
              setopt extended_history
              setopt hist_expire_dups_first
              setopt hist_ignore_dups
              setopt hist_ignore_space
              setopt hist_verify
              setopt share_history
            '')

            (lib.mkOrder 1001 ''
              # Re-apply Caelestia terminal colours for new interactive terminals.
              if [[ -t 1 && -r "''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/sequences.txt" ]]; then
                cat "''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/sequences.txt" > /dev/tty
              fi
            '')
          ];
          shellGlobalAliases = {
            UUID = "$(uuidgen | tr -d \\n)";
            G = "| grep";
          };
          shellAliases = {
            nf = "${pkgs.microfetch}/bin/microfetch";
            ff = ''${pkgs.fastfetch}/bin/fastfetch --logo "$(find ~/.config/fastfetch/pngs/ -name '*.png' | shuf -n 1)"'';
          };
        };
      }
    )
  ];
}
