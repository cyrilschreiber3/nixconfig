{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps:
      with ps; [
        nixd
        alejandra
        nixpkgs-fmt
      ]);
  };

  # enable Wayland support
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable vscode-server
  imports = [
    "${
      fetchTarball {
        url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
        sha256 = "1rq8mrlmbzpcbv9ys0x88alw30ks70jlmvnfr2j8v830yy5wvw7h";
      }
    }/modules/vscode-server/home.nix"
  ];
  services.vscode-server.enable = true;
}
