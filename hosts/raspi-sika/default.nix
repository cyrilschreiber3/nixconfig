{pkgs, ...}: let
  fromYAML = str: pkgs.lib.importJSON (pkgs.runCommand "yml" {nativeBuildInputs = [pkgs.yq];} ''echo "${str}" | yq . > $out'');
  wifiConfig = fromYAML (builtins.readFile ./../../dotfiles/wifi-networks.yaml);
  apInterface = "uap0";
  physicalInterface = "wlan0";
in {
  _module.args = {
    inherit apInterface physicalInterface wifiConfig fromYAML;
  };

  imports = [
    ./configuration.nix
    ./../../modules/zsh.nix
    ./../../modules/networking.nix
    ./../../modules/access-point.nix
    ./../../modules/audio.nix
  ];
}
