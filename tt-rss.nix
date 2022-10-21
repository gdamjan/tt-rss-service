{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-10-15";
    rev = "602e8684258062937d7f554ab7889e8e02318c96";
    sha256 = "sha256-n0uk7S7aJO9PXCcqCQDLe1ear9xPcFrzjjCdt0DnId8=";

    src = pkgs.fetchgit {
      url = "https://git.tt-rss.org/fox/tt-rss.git";
      inherit sha256 rev;
    };

    installPhase = ''
      mkdir -p $out/
      cp -R * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
