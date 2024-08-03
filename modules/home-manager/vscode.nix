{
  config,
  pkgs,
  ...
}: {
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
  services.vscode-server.enableFHS = true;
  services.vscode-server.installPath = "$HOME/.vscode";
  services.vscode-server.extraRuntimeDependencies = with pkgs; [
    nixd
    alejandra
    nixpkgs-fmt
  ];

  systemd.user.services.code-tunnel = {
    Unit = {
      Description = "Visual Studio Code Tunnel";
      After = ["network.target" "multi-user.target" "auto-fix-vscode-server.service" "graphical.target" "nix-deamon.socket"];
    };
    Service = {
      Type = "idle";
      Environment = "PATH=${pkgs.lib.makeBinPath [pkgs.vscode pkgs.bash pkgs.coreutils]}/bin:/run/current-system/sw/bin";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --cli-data-dir ${config.home.homeDirectory}/.vscode/cli tunnel service internal-run'";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = ["basic.target"];
    };
  };
}
