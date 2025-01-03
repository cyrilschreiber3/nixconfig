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
        sha256 = "09j4kvsxw1d5dvnhbsgih0icbrxqv90nzf0b589rb5z6gnzwjnqf";
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
      After = ["network.target" "multi-user.target" "nix-deamon.socket"];
    };
    Service = {
      Type = "idle";
      Environment = "PATH=${pkgs.lib.makeBinPath [pkgs.vscode pkgs.nixd pkgs.alejandra pkgs.nixpkgs-fmt pkgs.bash pkgs.coreutils]}/bin:/run/current-system/sw/bin";
      ExecStart = "${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --cli-data-dir ${config.home.homeDirectory}/.vscode/cli tunnel service internal-run";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = ["basic.target"];
    };
  };
}
