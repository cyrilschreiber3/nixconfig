{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "tokyonight-gtk-theme";

  src = pkgs.fetchurl {
    url = "https://cdn.the127001.ch/config/nixos/Tokyonight-Dark-BL-LB.zip";
    sha256 = "05pnd2h3xkbj84qgfpgglaxypn7r7vjc0w3x8k2v31n35m4k6a81";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/themes/
    ${pkgs.unzip}/bin/unzip $src -d $out/share/themes/
  '';
}
