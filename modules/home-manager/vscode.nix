{
  config,
  pkgs,
  ...
}: let
  vscode-extensions = import ./vscode-extensions.nix;
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace vscode-extensions;

    userSettings = {
      "workbench.iconTheme" = "vscode-icons";
      "workbench.colorTheme" = "Tokyo Night";

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.formatterPath" = "nixpkgs-fmt";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {"command" = ["nixpkgs-fmt"];};
        };
      };

      "files.autoSave" = "onFocusChange";
    };
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
