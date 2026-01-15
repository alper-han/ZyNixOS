{ self, pkgs, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        programs.bash = {
          enable = true;
          enableCompletion = true;
          historyFileSize = 100000;
          initExtra = ''
            # Direnv Hook
            if command -v direnv &>/dev/null; then
              eval "$(direnv hook bash)"
            fi
          '';
          # bashrcExtra = ''
          #   export TERM="xterm-256color" # Get correct colour
          # '';
          shellOptions = [
            "autocd" # change to named directory
            "cdspell" # autocorrects cd misspellings
            "cmdhist" # save multi-line commands in history as single line
            "dotglob"
            "histappend" # do not overwrite history
            "expand_aliases" # expand aliases
            "checkwinsize" # checks term size when bash regains control
          ];
          sessionVariables = {
            FZF_DEFAULT_OPTS = ''
              --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
              --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
              --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796'';
          };
          shellAliases = {
            lf = ''
                {
                  tmp="$(mktemp)"
                  # `command` is needed in case `lfcd` is aliased to `lf`
                  command lf -last-dir-path="$tmp" "$@"
                  if [ -f "$tmp" ]; then
                      dir="$(cat "$tmp")"
                      rm -f "$tmp"
                      if [ -d "$dir" ]; then
                          if [ "$dir" != "$(pwd)" ]; then
                              cd "$dir"
                          fi
                      fi
                  fi
              }
            '';
            fnew = ''
              if [ -d "$2" ]; then
                echo "Directory \"$2\" already exists!"
                return 1
              fi
              nix flake new $2 --template ${self}/dev-shells#$1
              cd $2
              direnv allow
            '';

            finit = ''
              nix flake init --template ${self}/dev-shells#$1
              direnv allow
            '';
            cdown = ''
              N=$1
              while [[ $((--N)) -gt  0 ]]
                do
                  echo "$N" |  figlet -c | lolcat &&  sleep 1
              done
            '';
            cls = "clear";
            tml = "tmux list-sessions";
            tma = "tmux attach";
            tms = "tmux attach -t $(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' | fzf | cut -d: -f1)";
            l = "${pkgs.eza}/bin/eza -lh  --icons=auto"; # long list
            ls = "${pkgs.eza}/bin/eza -1   --icons=auto"; # short list
            ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first"; # long list all
            ld = "${pkgs.eza}/bin/eza -lhD --icons=auto"; # long list dirs
            tree = "${pkgs.eza}/bin/eza --icons=auto --tree"; # dir tree
            vc = "code --disable-gpu"; # gui code editor
            nv = "nvim";
            nf = "${pkgs.microfetch}/bin/microfetch";
            ff = "${pkgs.fastfetch}/bin/fastfetch";
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
            find-store-path = ''function { nix-shell -p $1 --command "nix eval -f \"<nixpkgs>\" --raw $1" }'';
            update-input = "nix flake update $@";
            sysup = "nix flake update --flake ~/ZyNixOS && rebuild";

            # Directory Shortcuts.
            dots = "cd ~/ZyNixOS/";
          };
        };
      }
    )
  ];
}
