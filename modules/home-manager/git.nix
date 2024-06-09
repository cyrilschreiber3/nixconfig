{ config, pkgs, ... }:

{
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
      };
      user = {
        name = "cyrilschreiber3";
        email = "contact@cyrilschreiber.ch";
      };
    };
  };
}