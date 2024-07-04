{pkgs, ...}: {
  home.packages = with pkgs; [
    fzf
    pls
    thefuck
    oh-my-zsh
    nerdfonts
    chroma # required by the colorize plugin for omz
    zsh-autosuggestions
    zsh-nix-shell
    zsh-powerlevel10k
  ];

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "root"
        ];
      };
      # promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      plugins = [
        {
          # will source zsh-autosuggestions.plugin.zsh
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          # will source zsh-syntax-highlighting.plugin.zsh
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.8.0";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "powerlevel10k-config";
          src = ./../dotfiles/p10k;
          file = "p10k.zsh";
        }
        {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
      ];

      initExtraFirst = ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "ansible"
          "colored-man-pages"
          "colorize"
          "command-not-found"
          "cp"
          "dotenv"
          "encode64"
          "extract"
          "fzf"
          "git"
          "rsync"
          "screen"
          "ssh"
          "systemadmin"
          "thefuck"
          "vscode"
          "zsh-interactive-cd"
        ];
        extraConfig = ''
          # Display red dots whilst waiting for completion.
          COMPLETION_WAITING_DOTS="true"

          # Chroma plugin config
          ZSH_COLORIZE_TOOL=chroma
          ZSH_COLORIZE_STYLE="tokyonight-night"
          # VSCode plugin
          VSCODE="code"
          # fzf plugin
          DISABLE_FZF_AUTO_COMPLETION="true"

          # Prevent less from using pager everytime
          export PAGER="less -F -X"
        '';
      };
    };

    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [tokyonight-nvim];
      extraConfig = ''
        colorscheme tokyonight
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--highlight-line"
        "--info=inline-right"
        "--ansi"
        "--layout=reverse"
        "--border=none"
        "--color=bg+:#283457"
        "--color=bg:#16161e"
        "--color=border:#27a1b9"
        "--color=fg:#c0caf5"
        "--color=gutter:#16161e"
        "--color=header:#ff9e64"
        "--color=hl+:#2ac3de"
        "--color=hl:#2ac3de"
        "--color=info:#545c7e"
        "--color=marker:#ff007c"
        "--color=pointer:#ff007c"
        "--color=prompt:#2ac3de"
        "--color=query:#c0caf5:regular"
        "--color=scrollbar:#27a1b9"
        "--color=separator:#ff9e64"
        "--color=spinner:#ff007c"
      ];
    };
  };

  # home.file = {
  #   ".vim/tokyonight-night.vim"
  #     };
}
