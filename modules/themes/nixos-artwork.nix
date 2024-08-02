{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "nixos-artwork";

  src = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixos-artwork";
    rev = "de03e887f03037e7e781a678b57fdae603c9ca20";
    hash = "sha256-78FyNyGtDZogJUWcCT6A/T2MK87nGN/muC7ANH1b1V8=";
  };

  dontUnpack = false;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/
    cp $src/logo -r $out/share/
    cp $src/releases -r $out/share/
    cp $src/wallpapers -r $out/share/
  '';
}
