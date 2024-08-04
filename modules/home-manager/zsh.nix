{pkgs, ...}: {
  home.packages = with pkgs; [
    fzf
    pls
    lsd
    thefuck
    oh-my-zsh
    oh-my-posh
    nerdfonts
    chroma # required by the colorize plugin for omz
    zsh-autosuggestions
    zsh-nix-shell
    zsh-powerlevel10k
  ];

  programs = {
    zsh = {
      enable = true;
      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "root"
        ];
      };
      plugins = [
        {
          # will source zsh-autosuggestions.plugin.zsh
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
          };
        }
        {
          # will source zsh-syntax-highlighting.plugin.zsh
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.8.0";
            sha256 = "1yl8zdip1z9inp280sfa5byjbf2vqh2iazsycar987khjsi5d5w8";
          };
        }
        {
          name = "zsh-interactive-cd";
          src = pkgs.fetchFromGitHub {
            owner = "mrjohannchang";
            repo = "zsh-interactive-cd";
            rev = "master";
            sha256 = "1x1387zkzhzsnllvpciwnscvm3z77znlwsxrfkxjzvi8bz1w8vcg";
          };
          file = "zsh-interactive-cd.plugin.zsh";
        }
        # {
        #   name = "powerlevel10k-config";
        #   src = ./../dotfiles/p10k;
        #   file = "p10k.zsh";
        # }
        # {
        #   name = "zsh-powerlevel10k";
        #   src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        #   file = "powerlevel10k.zsh-theme";
        # }
      ];

      # initExtraFirst = ''
      #   # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      #   # Initialization code that may require console input (password prompts, [y/n]
      #   # confirmations, etc.) must go above this block; everything else may go below.
      #   if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      #     source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      #   fi
      # '';

      initExtra = ''
        # zsh-interactive-cd plugin
        bindkey '^I' zic-completion
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
          # "zsh-interactive-cd"
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
          FZF_BASE=${pkgs.fzf}/bin

          # Prevent less from using pager everytime
          export PAGER="less -F -X"
        '';
      };

      shellAliases = {
        ls = "lsd";
        "cd.." = "cd ..";
        ".." = "cd ..";
        fzf = ''
          FZF_DEFAULT_OPTS="--highlight-line \
          --info=inline-right \
          --ansi \
          --layout=reverse \
          --border=none \
          --color=bg+:#283457 \
          --color=bg:#16161e \
          --color=border:#27a1b9 \
          --color=fg:#c0caf5 \
          --color=gutter:#16161e \
          --color=header:#ff9e64 \
          --color=hl+:#2ac3de \
          --color=hl:#2ac3de \
          --color=info:#545c7e \
          --color=marker:#ff007c \
          --color=pointer:#ff007c \
          --color=prompt:#2ac3de \
          --color=query:#c0caf5:regular \
          --color=scrollbar:#27a1b9 \
          --color=separator:#ff9e64 \
          --color=spinner:#ff007c" \
          fzf
        '';
      };
    };

    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile "${pkgs.callPackage ./../dotfiles/omp/oh-my-posh-config.nix {}}/share/oh-my-posh/themes/p10k.omp.json"));
    };

    gnome-terminal = {
      enable = true;
      themeVariant = "dark";
      showMenubar = false;
      profile = {
        "273f07db-8f33-49f7-8909-da4b9946a21f" = {
          default = true;
          visibleName = "Tokyo Night";
          cursorShape = "block";
          transparencyPercent = 30;
          colors = {
            backgroundColor = "#1A1B26";
            foregroundColor = "#C0CAF5";
            cursor = {
              foreground = "#C0CAF5";
              background = "#C0CAF5";
            };
            palette = [
              "#414868"
              "#F7768E"
              "#9ECE6A"
              "#E0AF68"
              "#7AA2F7"
              "#BB9AF7"
              "#7DCFFF"
              "#A9B1D6"
              "#414868"
              "#F7768E"
              "#9ECE6A"
              "#E0AF68"
              "#7AA2F7"
              "#BB9AF7"
              "#7DCFFF"
              "#C0CAF5"
            ];
          };
        };
      };
    };

    # TheFuck is disabled because the current version (3.23) uses a deprecated module in python 3.12 and fails to build.
    # A new version has be released for this issue to go away.
    thefuck = {
      enable = true;
      enableZshIntegration = true;
      # enableInstantMode = true;
    };

    vim = {
      enable = true;
      extraConfig = ''
        syntax on
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetOptions = ["--height 7"];
      defaultOptions = [""];
    };

    # For command-not-found module
    # See this blog thread for more info https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807/9
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  dconf.settings = {
    "org/gnome/terminal/legacy/profiles:/:273f07db-8f33-49f7-8909-da4b9946a21f" = {
      default-size-collumns = 125;
      default-size-rows = 32;
      use-system-font = false;
      font = "MesloLGS Nerd Font 10";
    };
  };
}
