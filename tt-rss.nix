{ pkgs, php }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2020-09-15";
    rev = "4a074111b5bce126724bf06c9dc83880432e74c9";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = "0yyr4lhrs2vncmsdwfdin5fcb1hjgjidvdr296d3af2wz8gsknkk";
    };

    phpBin = php + "/bin/php";
    installPhase = ''
      mkdir $out
      cp -ra * $out/
      substituteAll ${./files/config.php.in} $out/config.php
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
