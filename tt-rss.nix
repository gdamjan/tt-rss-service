{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-01-09";
    rev = "4a4928ea254ff31034c50751c50a52c725166866";
    sha256 = "sha256-IHwvHPBdmoJuDnOfylWghD8eaEJMjoBm2sKz+5ymkYM=";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
