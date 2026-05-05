{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "tokyonight-kde-theme";

  src = pkgs.fetchFromGitHub {
    owner = "Jayy-Dev";
    repo = "Plasma-Tokyo-Night";
    rev = "plasma-6";
    hash = "sha256-Y+ta28tOYA5woAj9bcTunz5+9o3QUdKgeBAB//c48gk=";
  };

  dontUnpack = false;

  installPhase = ''
    mkdir -p $out/share/aurorae/themes
    cp $src/aurorae/* -r -d $out/share/aurorae/themes/

    mkdir -p $out/share/color-schemes/
    cp $src/colorscheme/* -d $out/share/color-schemes/

    cp $src/plasma -r -d $out/share/
  '';
}
