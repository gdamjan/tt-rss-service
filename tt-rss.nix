{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2020-08-29";
    rev = "67f02e2aa7b246ef7ca2b2aa4c62e2826327d219";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = "12gybaawwx8pgshj7lcpwm98waj7cqyy2jp5hsa3m9bnsd23rhld";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      cp ${./files/config.php} $out/config.php
    '';
}
