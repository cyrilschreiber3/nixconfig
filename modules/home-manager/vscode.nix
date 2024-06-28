{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps:
      with ps; [
        nil
        alejandra
        nixpkgs-fmt
        nodejs
        nodePackages.vscode-langservers-extracted
        nodePackages.yaml-language-server
        bun
        python3
      ]);
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
