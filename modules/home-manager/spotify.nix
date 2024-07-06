{
  inputs,
  # pkgs,
  ...
}: {
  # home.packages = with pkgs; [
  #   # spotify
  # ];

  imports = [inputs.spicetify-nix.homeManagerModule];
  programs.spicetify = {
    enable = true;
  };
}
