{...}: {
  programs.git = {
    enable = true;
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
        "https://gitlab.com/" = {
          insteadOf = [
            "gl:"
            "gitlab:"
          ];
        };
      };
      user = {
        name = "cyrilschreiber3";
        email = "contact@cyrilschreiber.ch";
      };
    };
  };
}
