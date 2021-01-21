{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2021-01-21";
    rev = "0d1336bd29ba32ef82dd0f80dde4f018e6ab32b9";
    sha256 = "1bnk3qb3782jx5n90n3hc8nn5z3gxl8a2lhdvsnfbxxfzym4n1p0";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      cp ${./files/config.php} $out/config.php
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
