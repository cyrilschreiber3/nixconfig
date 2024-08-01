{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "tokyonight-kde-colors";

  src = pkgs.fetchFromGitHub {
    owner = "nonetrix";
    repo = "tokyonight-kde";
    rev = "main";
    hash = "sha256-Uacbt86KsExXN6exsynCUrzY5AYkBk5SUDUWYPYEkL8=";
  };

  dontUnpack = false;

  installPhase = ''
    mkdir -p $out/share/color-schemes/
    cp $src/TokyoNight.colors -d $out/share/color-schemes/
  '';
}
