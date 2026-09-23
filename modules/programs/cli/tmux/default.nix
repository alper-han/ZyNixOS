{ pkgs, ... }:
let
in
{
  home-manager.sharedModules = [
    (_: {
      programs.tmux = {
        enable = true;
        clock24 = true;
        prefix = "C-b";
        keyMode = "emacs";
        # terminal = "screen-256color";
        # terminal = "tmux-256color";
        historyLimit = 100000;
        plugins = with pkgs.tmuxPlugins; [
          catppuccin
          sensible

          # {
          #   plugin = resurrect;
          #   extraConfig =
          #     ''
          #       set -g @resurrect-strategy-vim 'session'
          #       set -g @resurrect-strategy-nvim 'session'
          #       set -g @resurrect-capture-pane-contents 'on'
          #     ''
          # }
          # {
          #   plugin = continuum;
          #   extraConfig = ''
          #     set -g @continuum-restore 'on'
          #     set -g @continuum-boot 'on'
          #     set -g @continuum-save-interval '10'
          #     set -g @continuum-systemd-start-cmd 'start-server'
          #   '';
          # }
        ];
        extraConfig = ''
          # Options
          set -g @catppuccin_flavour 'mocha'
          set -g mouse on
          set -g allow-rename off
          set -g status-position top
          set -g base-index 1
          set -g pane-base-index 1
          set -g renumber-windows on
          set-window-option -g pane-base-index 1
          set -ga terminal-overrides ",*:Tc"

          # Keep tmux's default prefix bindings intact (f, r, w, x, *, -, c, z).
          bind-key -r F run-shell "tmux neww tmux-sessionizer"

          # Additional non-conflicting bindings.
          bind R source-file ~/.config/tmux/tmux.conf
          bind S choose-session
          bind u choose-session
          bind Y setw synchronize-panes
          bind -n C-M-c kill-pane
          bind X swap-pane -D

          # Select panes
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
          # Resize panes
          bind -n M-Left resize-pane -L 2
          bind -n M-Right resize-pane -R 2
          bind -n M-Up resize-pane -U 2
          bind -n M-Down resize-pane -D 2

          # Keep the convenient horizontal split alias; the default vertical
          # split remains available on prefix + ".
          bind | split-window -h -c "#{pane_current_path}"

          # Select windows
          bind -n S-Left  previous-window
          bind -n S-Right next-window
        '';
      };
    })
  ];
}
