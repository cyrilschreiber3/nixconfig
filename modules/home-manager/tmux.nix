{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tmuxConfig;

  python = pkgs.python313.withPackages (python-pkgs: [
    python-pkgs.pyfzf
    python-pkgs.libtmux
    python-pkgs.sh
    python-pkgs.configparser
  ]);
in {
  options.tmuxConfig = {
    enable = lib.mkEnableOption "Enable tmux module";
    prefix = lib.mkOption {
      type = lib.types.str;
      default = "C-a";
      description = "Set the prefix key";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.noto
      bc
      jq
    ];

    programs.tmux = {
      enable = true;
      clock24 = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      mouse = true;
      keyMode = "vi";

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes 'ssh vim nvim dev'
          '';
        }
        {
          plugin = tmuxPlugins.tokyo-night-tmux;
          extraConfig = ''
            set -g @tokyo-night-tmux_theme night
            set -g @tokyo-night-tmux_transparent 1
            set -g @tokyo-night-tmux_show_datetime 0
            set -g @tokyo-night-tmux_show_hostname 1
          '';
        }
      ];

      prefix = cfg.prefix;
      extraConfig = ''
        # split panes
        bind - split-window -h -c "#{pane_current_path}"
        bind _ split-window -v -c "#{pane_current_path}"

        bind k switch-client -l

        bind -n M-w select-pane -U
        bind -n M-a select-pane -L
        bind -n M-s select-pane -D
        bind -n M-d select-pane -R

        # Move panes
        bind -n M-Up select-pane -U \; swap-pane -s ! \; select-pane -U
        bind -n M-Left select-pane -L \; swap-pane -s ! \; select-pane -L
        bind -n M-Down select-pane -D \; swap-pane -s ! \; select-pane -D
        bind -n M-Right select-pane -R \; swap-pane -s ! \; select-pane -R

        bind r source-file ~/.config/tmux/tmux.conf; display-message "Tmux source file reloaded!"

        # Change color if the panes are synchronized (since it can be deadly)
        set -g pane-border-style '#{?pane_synchronized, fg=red, fg=#444444}'
        set -g pane-active-border-style '#{?pane_synchronized, fg=red, fg=${config.global.theme.colorPalette.color06}}'
        set -g status-style 'fg=#ffffff #{?pane_synchronized, bg=red, bg=default}'

        # Fix message text color
        set -g message-style 'bg=${config.global.theme.colorPalette.color04},fg=${config.global.theme.colorPalette.background}'

        bind f run-shell "tmux neww ${python}/bin/python ${pkgs.copyPathToStore ./../bin/tmuxScripts/tmux_select_session.py}"
        bind g run-shell "tmux neww ${python}/bin/python ${pkgs.copyPathToStore ./../bin/tmuxScripts/tmux_sessionizer.py}"
        bind h run-shell "tmux neww ${python}/bin/python ${pkgs.copyPathToStore ./../bin/tmuxScripts/tmux_select_pane.py}"
        #bind m run-shell "tmux neww ${python}/bin/python {pkgs.copyPathToStore ./../bin/tmuxScripts/tmux_ssh_group.py}"
        #bind j run-shell "tmux neww ${python}/bin/python {pkgs.copyPathToStore ./../bin/tmuxScripts/tmux_multi_ssh.py}"
        bind i set-window-option synchronize-panes\;
        bind o select-layout tiled
      '';
    };

    programs.zsh.shellAliases = {
      ta = "tmux attach";
    };

    programs.kitty.extraConfig = lib.mkIf pkgs.stdenv.isDarwin ''
      symbol_map U+1FBF0-U+1FBF9 IsovekaNF
    '';
  };
}
