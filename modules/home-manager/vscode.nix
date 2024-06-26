{
  config,
  pkgs,
  ...
}: let
  vscode-extensions = import ./vscode-extensions.nix;
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace vscode-extensions;

    # extensions = with pkgs.vscode-extensions; [
    #   # themes
    #   enkia.tokyo-night
    #   vscode-icons-team.vscode-icons

    #   # general
    #   esbenp.prettier-vscode
    #   christian-kohler.path-intellisense
    #   aaron-bond.better-comments
    #   #   chunsen.bracket-select
    #   tombonnike.vscode-status-bar-format-toggle
    #   donjayamanne.git-extension-pack
    #   github.vscode-github-actions
    #   marp-team.marp-vscode
    #   qwtel.sqlite-viewer
    #   rangav.vscode-thunder-client
    #   shardulm94.trailing-spaces

    #   # remote development
    #   ms-vscode-remote.remote-ssh
    #   ms-vscode-remote.remote-ssh-edit
    #   ms-vscode-remote.remote-containers
    #   ms-vscode-remote.remote-server
    #   ms-vscode-remote.remote-explorer

    #   # data files
    #   mikestead.dotenv
    #   redhat.vscode-yaml
    #   zainchen.json
    #   DotJoshJohnson.xml

    #   # ansible
    #   redhat.ansible
    #   dhoeric.ansible-vault

    #   # docker
    #   ms-azuretools.vscode-docker

    #   # html, css, js
    #   ms-vscode.live-server
    #   ritwickdey.LiveServer
    #   formulahendry.auto-close-tag
    #   formulahendry.auto-rename-tag
    #   pranaygp.vscode-css-peek
    #   rifi2k.format-html-in-php
    #   adrianwilczynski.format-selection-as-html
    #   ecmel.vscode-html-css
    #   syler.sass-indented

    #   # markdown
    #   yzane.markdown-pdf
    #   yzhang.markdown-all-in-one
    #   cweijan.vscode-office

    #   # nix
    #   bbenoist.Nix

    #   # node
    #   christian-kohler.npm-intellisense
    #   ChakrounAnas.turbo-console-log
    #   dbaeumer.vscode-eslint

    #   # powershell
    #   ms-vscode.PowerShell
    #   vin-liberty.powershell-snippets

    #   # python
    #   ms-python.python
    #   ms-python.vscode-pylance
    #   ms-python.debugpy

    #   # tailwindcss
    #   bradlc.vscode-tailwindcss
    #   Zarifprogrammer.tailwind-snippets
    # ];
  };

  # enable Wayland support
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  #   # enable vscode-server
  #   imports = [
  #     "${
  #       fetchTarball {
  #         url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
  #         sha256 = "1cybv5ls0vv55pr4a26jfqjrq1g78f91b570gl5rxqfdamwjq35q";
  #       }
  #     }/modules/vscode-server/home.nix"
  #   ];
  #   services.vscode-server.enable = true;
}
