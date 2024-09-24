{...}: {
  programs.zsh = {
    enable = true;
    shellInit = ''
      1=1
    '';
    enableLsColors = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      l = "ls";
    };
    ohMyZsh = {
      enable = true;
      theme = "gentoo";
      plugins = [];
    };
  };
}
