{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "oh-my-posh-config";

  src = ./p10k.yml;

  dontUnpack = true;

  buildInputs = [
    pkgs.yj
  ];

  buildPhase = ''
    yj -yj < $src > p10k.omp.json
  '';

  installPhase = ''
    mkdir -p $out/share/oh-my-posh/themes/
    cp p10k.omp.json $out/share/oh-my-posh/themes/
  '';
}
