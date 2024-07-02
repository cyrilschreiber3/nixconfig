{pkgs, ...}: {
  home.packages = with pkgs; [
    fzf
    pls
    thefuck
    ohmyzsh
    ohmyposh
    chroma # required by the colorize plugin for omz
    zsh-autosuggestions
    zsh-nix-shell
    zsh-powerlevel10k
  ];

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "root"
        ];
      };
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      plugins = [
        "git"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k/powerlevel10k";
        plugins = [
          "ansible"
          "bun"
          "colored-man-pages"
          "colorize"
          "command-not-found"
          "cp"
          "docker"
          "docker-compose"
          "dotenv"
          "encode64"
          "extract"
          "fancy-ctrl-z"
          "fzf"
          "git"
          "rsync"
          "screen"
          "ssh"
          "thefuck"
          "vscode"
          "zsh-interactive-cd"
        ];
        extraConfig = ''
        '';
      };
    };

    thefuck = {
      enable = true;
      alias = "fuck";
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [tokyonight-nvim];
      extraConfig = ''
        colorscheme tokyonight-night
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
        "--color=bg: #16161e"
        "--color=border: #27a1b9"
        "--color=fg: #c0caf5"
        "--color=gutter: #16161e"
        "--color=header: #ff9e64"
        "--color=hl+:#2ac3de"
        "--color=hl: #2ac3de"
        "--color=info: #545c7e"
        "--color=marker: #ff007c"
        "--color=pointer: #ff007c"
        "--color=prompt: #2ac3de"
        "--color=query: #c0caf5:regular"
        "--color=scrollbar: #27a1b9"
        "--color=separator: #ff9e64"
        "--color=spinner: #ff007c"
      ];
    };

    home.sessionVariables = {
      # omz plugin colorize
      ZSH_COLORIZE_TOOL = "chroma";
      ZSH_COLORIZE_STYLE = "tokyonight-night";

      # omz plugin vscode
      VSCODE = "code";
    };
  };
}
